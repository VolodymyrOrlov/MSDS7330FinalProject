#!flask/bin/python
from flask import Flask
import mysql.connector
from flask import jsonify 
from flask import Flask, abort, request 
import logging
import json
import os
import sys
import psycopg2
from pprint import pprint
import  plpygis
import simplejson
import psycopg2.extras

app = Flask(__name__)

connection = psycopg2.connect("dbname='postgres' user='postgres' host='localhost' password='' port='5432'") #Vlad
connection.set_session(autocommit=True)
logging.basicConfig(level=logging.INFO)

# postgres   
########################################################################3
# update user
########################################################################################
@app.route('/api/game/user', methods=['POST'])
def user_registration():
	try:
		datauser=request.get_json()

		logging.info('registering new user {}'.format(datauser))

		cursor = connection.cursor()

		#check if userid exist	
		cursor.execute("SELECT * FROM userdata WHERE userid=%s;" , [datauser['userid'],])
						
		if cursor.fetchone()==None:	
			i=0
			create_string = "INSERT INTO userdata("
			for key in datauser:
				if i==0:
					create_string = create_string+str(key)
					i=1
				else:	
					create_string = create_string+","+str(key)
			i=0		
			create_string = create_string+ ") VALUES("+"'"  
			for key in datauser:
				if i==0:
					create_string = create_string+str(datauser[key])
					i=1
				else:	
					create_string = create_string+"'"+","+"'"+str(datauser[key])
			create_string = create_string +"'"+ ")"
			cursor.execute(create_string)

		else:
			def type_format(v):
				if isinstance(v, float) or isinstance(v, int):
					return v
				else:
					return "'{}'".format(v)

			keys = [k for k in datauser.keys() if k != 'userid']
			sql = """update userdata set {} where userid = '{}'""".format(', '.join(map(lambda k: k + '=' + type_format(datauser[k]), keys)), datauser['userid'])
			print(sql)
			cursor.execute(sql)


	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	return ''

###################################################################################################
# sync user data
########################################################################################

@app.route('/api/game/user/<userid>', methods=[ 'GET'])
def user(userid):

	logging.info('requested data for user with ID {}'.format(userid))

	cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
	try:
		cursor.execute("SELECT * FROM userdata WHERE userid=%s" , [userid,])
		rows = cursor.fetchall()
		if not rows:
			name = 'Player 1'
			sql = """
			INSERT INTO userdata (userid, firstname) 
			VALUES ('{userid}', '{firstname}')
			""".format(userid=userid, firstname=name)

			cursor.execute(sql)

			return jsonify({'userid': userid, 'name': name})
		else:
			return jsonify({'userid': rows[0]['userid'], 'name': rows[0]['firstname']})

	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	return ''

###################################################################################################
# user current status
########################################################################################
@app.route('/api/game/user-score/<userid>', methods=[ 'GET'])
def user_info(userid):

	logging.info('requested scores of user with ID {}'.format(userid))

	global query_result
	cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
	try:

		cursor.execute("""
		SELECT scorecategory, sum(userscore) as score
				FROM 	totalgamescore
				WHERE  userid='{userid}'
				group by scorecategory""".format(userid=userid))

		rows = cursor.fetchall()
		response = {}
		for row in rows:
			response[row['scorecategory']] = row['score']
		return jsonify(response)

	except Exception as e:
		print(e)
		return '', 500
	finally:
		if cursor:
			cursor.close()

##########################################################################################################3	
# location registration
########################################################################################
@app.route('/api/game/location/<userid>', methods=['POST'])
def location(userid):

	logging.info('New location for user with ID {} reported'.format(userid))

	cursor = connection.cursor()
	try:
		location_data=request.get_json()

		sql = """
		INSERT INTO templocation (userid, longtitude, latitude) 
			VALUES ('{userid}', {longtitude}, {latitude})
			ON CONFLICT (userid) DO UPDATE 
			  SET longtitude = excluded.longtitude, 
				  latitude = excluded.latitude
		""".format(userid=userid, longtitude=location_data['longtitude'], latitude=location_data['latitude'])

		cursor.execute(sql)

	except Exception as e:
		print(e)
		return '', 500

	finally:
		if cursor:
			cursor.close()

	return '', 200

###################################################################################################
# pull list tokens around
########################################################################################
@app.route('/api/game/getlist/<userid>/<r>', methods=['GET'])
def getlist(userid,r):

	global query_result
	try:
		cursor = connection.cursor()

		cursor.execute("SELECT * FROM templocation WHERE userid=%s;" , [userid])

		query_result_location = [ dict(line) 
			for line in [zip([ column[0] 
				for column in cursor.description], row) 
					for row in cursor.fetchall()] ]

		cursor.execute(
							"SELECT  obj.objectid, obj.objectcategory, pointlongtitude as longtitude, pointlatitude as latitude "
							"FROM 	objectlocation  as objloc, "
								"object as obj "
								"CROSS JOIN (SELECT ST_MakePoint(%s,%s)::geography AS ref_geom) AS r "
								"WHERE ST_DWithin(ST_MakePoint(pointlatitude, pointlongtitude)::geography, ref_geom, %s) "
								"and objloc.objectid=obj.objectid "
								"and obj.objectid not in (select totalgamescore.objectid from totalgamescore)" ,
			(query_result_location[0]['latitude'], query_result_location[0]['longtitude'],r))

		query_result = [ dict(line) 
			for line in [zip([ column[0] 
				for column in cursor.description], row) 
					for row in cursor.fetchall()] ]

	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	logging.info('Found {} objects around user with ID {}'.format(len(query_result), userid))

	return jsonify({'Token_List': query_result})

###################################################################################################
# collection acception
########################################################################################
@app.route('/api/game/collection_reg/<userid>', methods=['POST'])
def collection_reg(userid):
	
	global query_result
	cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
	try:
		data=request.get_json()

		objectid = data['objectid'].strip()

		logging.info('User with ID {} reported a collision with {}!'.format(userid, objectid))

		sql = """
		insert into totalgamescore(userid, userscore, scorecategory, eventtime, objectid)
		(select '{userid}', objectbasescore, objectcategory, current_timestamp, objectid from object where objectid = '{objectid}')
		ON CONFLICT DO NOTHING
		""".format(userid=userid, objectid=objectid)

		cursor.execute(sql)

		cursor.execute("""
		SELECT scorecategory, sum(userscore) as score
				FROM 	totalgamescore
				WHERE  userid='{userid}'
				group by scorecategory""".format(userid=userid))

		rows = cursor.fetchall()
		response = {}
		for row in rows:
			response[row['scorecategory']] = row['score']
		return jsonify(response)

	except Exception as e:
		print(e)
		return '', 500
	finally:
		if cursor:
			cursor.close()

## Starts the server for serving Rest Services
if __name__ == '__main__':
    app.run(host='192.168.1.68', debug=False)