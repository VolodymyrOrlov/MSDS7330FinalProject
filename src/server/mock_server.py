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
import random

app = Flask(__name__)

connection = psycopg2.connect("dbname='postgres' user='postgres' host='localhost' password='' port='5432'")

# postgres   
########################################################################3
# user  registration  
########################################################################################
@app.route('/api/game/user', methods=[ 'POST'])
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
	
		cursor.execute("SELECT sum(userscore),scorecategory,storyid "
						"FROM totalgamescore WHERE userid=%s	 "
						"group by scorecategory,storyid", [userid])
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
@app.route('/api/game/location/<userid>', methods=['POST'])
def location(userid):
	try:
		location_data=request.get_json()
		logging.warning("Connecting to DB")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")

		sql = """
		INSERT INTO templocation (userid, longtitude, latitude) 
			VALUES ('{userid}', {longtitude}, {latitude})
			ON CONFLICT (userid) DO UPDATE 
			  SET longtitude = excluded.longtitude, 
				  latitude = excluded.latitude
		""".format(userid=userid, longtitude=location_data['longtitude'], latitude=location_data['latitude'])

		cursor.execute(sql)
		connection.commit()

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

	return jsonify({'Token_List': [
		{
			"objectid": "collect06",
			"objectcategory": "art",
			"pointlatitude": -121.976377,
			"pointlongtitude": 37.309260
		},
		{
			"objectid": "collect05",
			"objectcategory": "politics",
			"pointlatitude": -121.975958,
			"pointlongtitude": 37.309146
		}
	]})


###################################################################################################
# collection acception
########################################################################################
@app.route('/api/game/collection_reg/<userid>', methods=['POST'])
def collection_reg(userid):

	object_data = request.get_json()

	assert(userid)
	assert('objectcategory' in object_data)
	assert('objectid' in object_data)
	assert('pointlatitude' in object_data)
	assert('pointlongtitude' in object_data)

	if random.randint(1,10) >= 5:
		return jsonify({
			'total_score': 1000,
			'story': """
			Bacon ipsum dolor amet pig strip steak ham hock pastrami kielbasa buffalo, fatback t-bone cupim brisket pork chop.
			 Shank ribeye kevin tri-tip pork chop fatback swine venison biltong frankfurter.
			  Leberkas chuck tail, pork loin pastrami strip steak doner shank tenderloin.
			   Short ribs shank beef ribs andouille. Doner shank rump boudin.
				Corned beef frankfurter meatball doner cow salami filet mignon picanha beef ribs jowl rump spare ribs pork belly."""
		})
	else:
		return jsonify({
			'total_score': 1000
		})

## Starts the server for serving Rest Services 
if __name__ == '__main__':
    app.run(host='192.168.1.68', debug=True)