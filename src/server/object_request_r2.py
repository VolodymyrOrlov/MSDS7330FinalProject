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

#connection = psycopg2.connect("dbname='postgres' user='postgres' host='localhost' password='' port='5432'") #Vlad
connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'") #Vit

# postgres   
########################################################################3
# user  registration  
########################################################################################
@app.route('/api/game/user', methods=['POST'])
def user_registration():
	try:
		datauser=request.get_json()
		logging.warning("Connecting to DB")

		cursor = connection.cursor()
		logging.warning("Connection with DB established")	

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
			connection.commit()

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
			connection.commit()


	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	return ''

###################################################################################################
# user private data
########################################################################################

@app.route('/api/game/user/<userid>', methods=[ 'GET'])
def user(userid):

	cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
	try:
		cursor.execute("SELECT * FROM userdata WHERE userid=%s;" , [userid,])
		rows = cursor.fetchall()
		if not rows:
			return '', 404
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
	try:
		#datauser=request.get_json()
		logging.warning("Connecting to DB")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")	
	
		cursor.execute("SELECT sum(userscore),scorecategory "
						"FROM totalgamescore WHERE userid=%s	 "
						"group by scorecategory ", [userid])
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

	if not query_result:
		return jsonify({'UserInfo': 'user has no score'})
	else:
		return jsonify({'UserInfo': query_result})

##########################################################################################################3	
# location registration
########################################################################################
@app.route('/api/game/location', methods=['POST'])
def location():
	try:
		datauser=request.get_json()
		print (datauser)
		logging.warning("Connecting to DB")
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")	
		#check if userid exist	
		cursor.execute("SELECT * FROM templocation WHERE userid=%s;" , [datauser['userid'],])
						
		if cursor.fetchone()==None:	
			i=0
			create_string = "INSERT INTO templocation("
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
			
		else:
			create_string = "UPDATE templocation SET longtitude=" + datauser['longtitude']+",latitude="+datauser['latitude']+" WHERE userid='"+datauser['userid']+"'"

		cursor.execute(create_string)
		connection.commit()
		message='Location has been registered'

	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	return jsonify({'Report': message})

###################################################################################################
# pull list tokens around
########################################################################################
@app.route('/api/game/getlist/<userid>/<r>', methods=['GET'])
def getlist(userid,r):

	global query_result
	try:
		logging.warning("Connecting to DB")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")

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
								"WHERE ST_DWithin(geom, ref_geom, %s) "
								"and objloc.objectid=obj.objectid "
								"and obj.objectid not in (select totalgamescore.objectid from totalgamescore)" , (query_result_location[0]['longtitude'],query_result_location[0]['latitude'],r))

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

	return jsonify({'Token_List': query_result})

###################################################################################################
# collection acception
########################################################################################
@app.route('/api/game/collection_reg', methods=['POST'])
def collection_reg():
	
	global query_result
	try:
		datauser=request.get_json()

		logging.warning("Connecting to DB")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")	
				
		i=0
		create_string = "INSERT INTO totalgamescore("
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
		print (create_string)
		cursor.execute(create_string)
		connection.commit()

		cursor.execute("SELECT DISTINCT storyfile, q.totalscore "
						"FROM "
								"segment as seg, ( "
								"SELECT sum(userscore) as totalscore, scorecategory "
								"FROM totalgamescore "
								"WHERE userid=%s "
								"group by scorecategory "
								") as q "
							"WHERE "
								"q.scorecategory=seg.segmentcategory "
								"and q.totalscore>=seg.segmentthreshold "
								"and seg.segmentcategory=%s ", [datauser['userid'],datauser['scorecategory']])
					 
		if cursor.rowcount==0:	
			print (datauser)
			cursor.execute("SELECT sum(userscore),scorecategory "
								"FROM 	totalgamescore "
								"WHERE  userid=%s "
								"group by scorecategory " , [datauser['userid'],])

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

	return jsonify({'Report': query_result})

## Starts the server for serving Rest Services 
if __name__ == '__main__':
    app.run(debug=True)
    #app.run(host='192.168.1.68', debug=True)  #Vlad

##########################################################################################################3	
# location registration  Vlad version for postgres >9.5
########################################################################################
#@app.route('/api/game/location/<userid>', methods=['POST'])
#def location(userid):
#	try:
#		location_data=request.get_json()
#		logging.warning("Connecting to DB")
#		cursor = connection.cursor()
#		logging.warning("Connection with DB established")
#
#		sql = """
#		INSERT INTO templocation (userid, longtitude, latitude) 
#			VALUES ('{userid}', {longtitude}, {latitude})
#			ON CONFLICT (userid) DO UPDATE SET longtitude = excluded.longtitude,latitude = excluded.latitude
#		""".format(userid=userid, longtitude=location_data['longtitude'], latitude=location_data['latitude'])
#
#		cursor.execute(sql)
#		connection.commit()
#
#	except Exception as e:
#		print(e)
#		return '', 500
#
#	finally:
#		if cursor:
#			cursor.close()
#
#	return '', 200