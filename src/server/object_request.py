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

app = Flask(__name__)

# postgres   
########################################################################3
# user  registration  
########################################################################################
@app.route('/api/game/user_registration', methods=[ 'POST'])
def user_registration():
	try:
		datauser=request.get_json()
		logging.warning("Connecting to DB")
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
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

			message='new user added'
		else:
			message='user already exist'
	except Exception as e:
		print("Error [%r]" % (e))
		sys.exit(1)
	finally:
		if cursor:
			cursor.close()

	return jsonify({'Registration': message})
###################################################################################################
# user current status
########################################################################################
@app.route('/api/game/user_info/<userid>', methods=[ 'GET'])
def user_info(userid):
	try:
		#datauser=request.get_json()
		logging.warning("Connecting to DB")
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
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
@app.route('/api/game/getlocation', methods=['POST'])
def getlocation():
	try:
		datauser=request.get_json()
		print (datauser)
		logging.warning("Connecting to DB")
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
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
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
		cursor = connection.cursor()
		logging.warning("Connection with DB established")

		cursor.execute("SELECT * FROM templocation WHERE userid=%s;" , [userid])

		query_result_location = [ dict(line) 
			for line in [zip([ column[0] 
				for column in cursor.description], row) 
					for row in cursor.fetchall()] ]

		cursor.execute("SELECT DISTINCT * "
						"FROM ( "
							"SELECT DISTINCT loc.siteid, obj.objectcategory,obj.objectscore,pointlongtitude,pointlatitude,objloc.collectid "
							"FROM  ( "
								"SELECT  Latitude, Longitude, siteid, geom, ST_Distance(geom, ref_geom) AS distance "
								"FROM sitelocation " 
								"CROSS JOIN (SELECT ST_MakePoint(%s,%s)::geography AS ref_geom) AS r "
								"WHERE ST_DWithin(geom, ref_geom, %s) "
								"ORDER BY ST_Distance(geom, ref_geom) "
								") as q, "
								"sitelocation as loc, "
								"story as story, "
								"objectlocation as objloc, "
								"object as obj, "
								"geopointslocation as geo "
							"WHERE "
									"loc.siteid=q.siteid "
									"and loc.siteid=story.siteid "
									"and story.storyid=objloc.storyid "
									"and objloc.geopointid=geo.geopointid "
									"and objloc.objectid=obj.objectid " 
								") as w "
								"WHERE w.collectid not in (select totalgamescore.collectid from totalgamescore)" , (query_result_location[0]['longtitude'],query_result_location[0]['latitude'],r))

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
		print (datauser)
		logging.warning("Connecting to DB")
		connection = psycopg2.connect("dbname='game' user='postgres' host='localhost' password='nikon123' port='5432'")
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

		cursor.execute(create_string)
		connection.commit()

		cursor.execute("SELECT seg.storyfile as availablefile,seg.segmentcategory,q.sum as totalpoints "
					"FROM segment as seg, ( "
					"SELECT sum(userscore),scorecategory,storyid "
					"FROM totalgamescore "
					"WHERE userid='user01' "
					"group by scorecategory,storyid "
					") as q "
					"WHERE "
						"q.storyid=seg.storyid "
						"and q.scorecategory=seg.segmentcategory "
						"and q.sum>seg.segmentthreshold " , str(datauser['userid']))
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


#SELECT Store_Number, store_name, StreetAddress, ST_Distance(geom, ref_geom) AS distance,story.storyname,site.siteid, seg.segmentcategory
#FROM 	sitelocation5 as site, 
#	story as story,
#	segment as seg
	
#CROSS JOIN (SELECT ST_MakePoint(-122.325959, 47.625138)::geography AS ref_geom) AS r  
#WHERE ST_DWithin(geom, ref_geom, 1000)  
#	and story.siteid=site.siteid
#	and story.storyid=seg.storyid
#ORDER BY ST_Distance(geom, ref_geom);  

#class DatabaseConnection:
 #   def __init__(self):
 #       try:
 #           self.connection = psycopg2.connect(
 #               "dbname='starbucks' user='postgres' host='localhost' password='nikon123' port='5432'")
 #           self.connection.autocommit = True
 #           self.cursor = self.connection.cursor()
 #       except:
 #           pprint("Cannot connect to datase")
#
#    def create_table(self):
#        create_table_command = "CREATE TABLE pet(id serial PRIMARY KEY, name varchar(100), age integer NOT NULL)"
#        self.cursor.execute(create_table_command)