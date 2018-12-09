SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP SCHEMA if exists topology CASCADE;
DROP TABLE IF EXISTS object cascade;
DROP TABLE IF EXISTS objectlocation cascade;
DROP TABLE IF EXISTS segment cascade;
DROP TABLE IF EXISTS story cascade;
DROP TABLE IF EXISTS templocation cascade;
DROP TABLE IF EXISTS totalgamescore cascade;
DROP TABLE IF EXISTS userdata cascade;
DROP TABLE IF EXISTS usersegment cascade;

CREATE SCHEMA topology;

ALTER SCHEMA topology OWNER TO vorl;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE object (
    objectid character varying(30) NOT NULL,
    objectcategory character(30) NOT NULL,
    objectbasescore integer NOT NULL
);

ALTER TABLE public.object OWNER TO vorl;

CREATE TABLE objectlocation (
    objectlocationid character varying(30) NOT NULL,
    objectid character varying(30) NOT NULL,
    pointlatitude double precision NOT NULL,
    pointlongtitude double precision NOT NULL,
    geom geometry(Point,4326)
);

ALTER TABLE public.objectlocation OWNER TO vorl;

CREATE TABLE segment (
    segmentid character varying(15) NOT NULL,
    segmentcategory character(10),
    segmentthreshold integer,
    storyfile text,
    storyid character varying(15)
);

ALTER TABLE public.segment OWNER TO vorl;

CREATE TABLE usersegment (
    segmentid character varying(15) NOT NULL,
    userid character varying(255) NOT NULL
);

ALTER TABLE public.usersegment OWNER TO vorl;

CREATE TABLE story (
    storyid character varying(30) NOT NULL,
    storyname character varying(30) NOT NULL
);

ALTER TABLE public.story OWNER TO vorl;

CREATE TABLE templocation (
    userid character varying(255) NOT NULL,
    longtitude double precision NOT NULL,
    latitude double precision NOT NULL
);

ALTER TABLE public.templocation OWNER TO vorl;

CREATE TABLE totalgamescore (
    userid character varying(255) NOT NULL,
    userscore integer NOT NULL,
    scorecategory text NOT NULL,
    eventtime timestamp without time zone NOT NULL,
    objectid character varying(30) NOT NULL
);

ALTER TABLE public.totalgamescore OWNER TO vorl;

CREATE TABLE userdata (
    userid character varying(255) NOT NULL,
    firstname text
);

ALTER TABLE public.userdata OWNER TO vorl;

SET search_path = topology, pg_catalog;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY object
    ADD CONSTRAINT object_pkey PRIMARY KEY (objectid);

ALTER TABLE ONLY objectlocation
    ADD CONSTRAINT objectlocation_pkey PRIMARY KEY (objectlocationid);

ALTER TABLE ONLY segment
    ADD CONSTRAINT segment_pkey PRIMARY KEY (segmentid);

ALTER TABLE ONLY story
    ADD CONSTRAINT story_pkey PRIMARY KEY (storyid);

ALTER TABLE ONLY templocation
    ADD CONSTRAINT templocation_pkey PRIMARY KEY (userid);

ALTER TABLE ONLY totalgamescore
    ADD CONSTRAINT totalgamescore_pkey PRIMARY KEY (userid, objectid);

ALTER TABLE ONLY userdata
    ADD CONSTRAINT userdata_pkey PRIMARY KEY (userid);

CREATE INDEX idx_objectlocation ON objectlocation USING gist (geom);

ALTER TABLE ONLY totalgamescore
    ADD CONSTRAINT foreign_key01 FOREIGN KEY (userid) REFERENCES userdata(userid);

ALTER TABLE ONLY segment
    ADD CONSTRAINT foreign_key01 FOREIGN KEY (storyid) REFERENCES story(storyid);


ALTER TABLE ONLY objectlocation
    ADD CONSTRAINT foreign_key01 FOREIGN KEY (objectid) REFERENCES object(objectid);


ALTER TABLE ONLY templocation
    ADD CONSTRAINT foreign_key01 FOREIGN KEY (userid) REFERENCES userdata(userid) ON UPDATE CASCADE ON DELETE CASCADE;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM vorl;
GRANT ALL ON SCHEMA public TO vorl;
GRANT ALL ON SCHEMA public TO PUBLIC;

-- Vlad's house

INSERT INTO object VALUES('object1', 'culture', 5);
INSERT INTO object VALUES('object2', 'culture', 5);
INSERT INTO object VALUES('object3', 'culture', 5);
INSERT INTO object VALUES('object4', 'culture', 5);
INSERT INTO object VALUES('object5', 'culture', 5);

INSERT INTO object VALUES('object6', 'politics', 5);
INSERT INTO object VALUES('object7', 'politics', 5);
INSERT INTO object VALUES('object8', 'politics', 5);
INSERT INTO object VALUES('object9', 'politics', 5);
INSERT INTO object VALUES('object10', 'politics', 5);

INSERT INTO object VALUES('object11', 'technology', 5);
INSERT INTO object VALUES('object12', 'technology', 5);
INSERT INTO object VALUES('object13', 'technology', 5);
INSERT INTO object VALUES('object14', 'technology', 5);
INSERT INTO object VALUES('object15', 'technology', 5);

INSERT INTO objectlocation VALUES('objectlocation1', 'object1', 37.309244, -121.976347, NULL);
INSERT INTO objectlocation VALUES('objectlocation2', 'object2', 37.309173, -121.975994, NULL);
INSERT INTO objectlocation VALUES('objectlocation3', 'object3', 37.309634, -121.975983, NULL);
INSERT INTO objectlocation VALUES('objectlocation4', 'object4', 37.310252, -121.975972, NULL);
INSERT INTO objectlocation VALUES('objectlocation5', 'object5', 37.310597, -121.975642, NULL);

INSERT INTO objectlocation VALUES('objectlocation6', 'object6', 37.310599, -121.975228, NULL);
INSERT INTO objectlocation VALUES('objectlocation7', 'object7', 37.310958, -121.974963, NULL);
INSERT INTO objectlocation VALUES('objectlocation8', 'object8', 37.311329, -121.974985, NULL);
INSERT INTO objectlocation VALUES('objectlocation9', 'object9', 37.311386, -121.974539, NULL);
INSERT INTO objectlocation VALUES('objectlocation10', 'object10', 37.311459, -121.973972, NULL);

INSERT INTO objectlocation VALUES('objectlocation11', 'object11', 37.311431, -121.972798, NULL);
INSERT INTO objectlocation VALUES('objectlocation12', 'object12', 37.311427, -121.972268, NULL);
INSERT INTO objectlocation VALUES('objectlocation13', 'object13', 37.311090, -121.972167, NULL);
INSERT INTO objectlocation VALUES('objectlocation14', 'object14', 37.310773, -121.972023, NULL);
INSERT INTO objectlocation VALUES('objectlocation15', 'object15', 37.310204, -121.972013, NULL);

-- SMU

INSERT INTO object VALUES('object16', 'culture', 5);
INSERT INTO object VALUES('object17', 'culture', 5);
INSERT INTO object VALUES('object18', 'culture', 5);
INSERT INTO object VALUES('object19', 'culture', 5);
INSERT INTO object VALUES('object20', 'culture', 5);

INSERT INTO object VALUES('object21', 'politics', 5);
INSERT INTO object VALUES('object22', 'politics', 5);
INSERT INTO object VALUES('object23', 'politics', 5);
INSERT INTO object VALUES('object24', 'politics', 5);
INSERT INTO object VALUES('object25', 'politics', 5);

INSERT INTO object VALUES('object26', 'technology', 5);
INSERT INTO object VALUES('object27', 'technology', 5);
INSERT INTO object VALUES('object28', 'technology', 5);
INSERT INTO object VALUES('object29', 'technology', 5);
INSERT INTO object VALUES('object30', 'technology', 5);

INSERT INTO objectlocation VALUES('objectlocation16', 'object16', 32.844379, -96.784926, NULL);
INSERT INTO objectlocation VALUES('objectlocation17', 'object17', 32.843927, -96.781660, NULL);
INSERT INTO objectlocation VALUES('objectlocation18', 'object18', 32.843841, -96.784987, NULL);
INSERT INTO objectlocation VALUES('objectlocation19', 'object19', 32.845763, -96.782263, NULL);
INSERT INTO objectlocation VALUES('objectlocation20', 'object20', 32.845448, -96.779870, NULL);

INSERT INTO objectlocation VALUES('objectlocation21', 'object21', 32.846010, -96.779793, NULL);
INSERT INTO objectlocation VALUES('objectlocation22', 'object22', 32.846289, -96.785436, NULL);
INSERT INTO objectlocation VALUES('objectlocation23', 'object23', 32.843263, -96.785368, NULL);
INSERT INTO objectlocation VALUES('objectlocation24', 'object24', 32.841041, -96.784964, NULL);
INSERT INTO objectlocation VALUES('objectlocation25', 'object25', 32.839398, -96.785086, NULL);

INSERT INTO objectlocation VALUES('objectlocation26', 'object26', 32.838454, -96.785492, NULL);
INSERT INTO objectlocation VALUES('objectlocation27', 'object27', 32.838650, -96.781957, NULL);
INSERT INTO objectlocation VALUES('objectlocation28', 'object28', 32.842090, -96.786223, NULL);
INSERT INTO objectlocation VALUES('objectlocation29', 'object29', 32.843072, -96.782618, NULL);
INSERT INTO objectlocation VALUES('objectlocation30', 'object30', 32.842596, -96.782774, NULL);

INSERT INTO story VALUES('story1', 'Alpha Centauri');

INSERT INTO segment VALUES('segment1', 'culture', 5, 'The abandoned city appears to have been well preserved due to its massive walls. This is excellent as it should also preserve all the dwellings, tools, art, and such within. No city of comparable size or as well preserved can be found anywhere near this place. In fact, the environment is so hostile that we would never have thought that this planet sustained life, much less complex civilizations. It is to think that not only were we able to find intelligent life but that we may be able to figure out how they lived. However, we must be wary that cultures that grow in isolation often fail to resemble the people and cultures everywhere else. Every preliminary conclusion must be taken with a grain of salt until we have more information.', 'story1');
INSERT INTO segment VALUES('segment2', 'culture', 10, 'All the remains in the city appear to have the same aesthetic of jagged surfaces made from the same white material. Back on earth, cities tend to have vistas that vary according to the time they were constructed or the person who ordered their construction. Buildings, cars, lights, lampposts, and walkways all vary by when they were built or who was hired to build them. Most objects and buildings here look the same. Everything appears to have the same white and clean, if not Spartan look to them. This somewhat implies a single dominant culture, or at least that someone wants to make it look that way. After all, we don’t know if this is a genuine city that housed civilians or some kind of military or commercial outpost.  Perhaps this city had a purpose.', 'story1');
INSERT INTO segment VALUES('segment3', 'culture', 15, 'We have yet to find a single grave, or any kind of organic material, which is going to make it really difficult to learn about these beings’ biology and anatomy. It’s also going to be difficult to know exactly how many beings actually lived here at a time without some way to gauge birthrates, death rates or longevity. However, we must be wary not to blinded by earth bias. we don’t know if this implies longevity or perhaps a particular form of disposing of the dead, like cremation. We can’t even assume that the beings were a traditional form of life. We can only lament that they have all disappeared and have not even left remains for us to analyze. Hopefully, they left peacefully and voluntarily.', 'story1');
INSERT INTO segment VALUES('segment4', 'culture', 20, 'Everything small enough to be picked up and held has a generally pleasant feel to it, at least by the standards on earth. Some of that could be the varying gravity, but this is also in spite of the larger size of everything. This craftsmanship present in our technological samples contrasts with the utter lack of public displays of art anywhere in the city. The ubiquity of the material implies that it has a utilitarian purpose, opposed to cultural or artistic one. Case in point, only military installations and penal colonies back on earth tend to have everything be the same color while having little to no unnecessary decorations. Going on first impressions: the beings appear to be far more motivated by utility and uniformity than by artistry and variety.Then again, maybe their eyes work differently from ours. Maybe what they can see through their eyes is very different than what we can see through ours.  Let’s hope that this is indeed a peaceful, civilian outpost and that we are using our limited experience to assume too much. If it isn’t a civilian settlement, however, we are likely to get a very biased look at the beings’ culture.', 'story1');
INSERT INTO segment VALUES('segment5', 'culture', 25, 'The team is waiting for permission to go underground and explore what may be beneath the city. We shouldn’t get our hopes up, as the request may not get approved and the city may not have much of an underground portion at all. In the chance that there were an underground portion of the city, we would have a second chance to find remains, waste, or some indicator of what food the inhabitants ate. There’s even a tiny possibility that someone is still alive but hiding beneath the city. This is all an incredibly motivating prospect, since conclusions about how the beings lived have been incredibly limited without having decoded communiques. There are linguists, for example, who will be crucial in understanding the beings’ language but currently have very little to do. In the meantime, they can aid the xenoarchaeologists in a dig. Is there something they are afraid we are going to discover?', 'story1');
INSERT INTO segment VALUES('segment6', 'politics', 5, 'This is the only city of this size that can be seen anywhere on the planet. There is definitely evidence that there were other cities and settlements on this planet, but this is by far the biggest that we’ve been able to find. It’s also unusual by earth standards in that the largest cities on earth tend to be near water or on important trade routes. This city, however, is tucked away on arid steppes. The beings that built this city definitely went out of their way to isolate themselves from their environment, from valuable resources, and from others. As such, one would think that this should be one of the smaller cities on the planet. Since, nothing this big is ever built without a purpose. It makes me wonder just what the city is for.', 'story1');
INSERT INTO segment VALUES('segment7', 'politics', 10, 'No statues have survived. If there were statues or monuments, we could have gotten a sense of what or who the beings idolized. We might have even been able to know what the beings looked like. With no statues or monuments, however, we can’t necessarily conclude that they did not have any kings or idols. The city’s layout is also unusual in that there’s a doorway in the center. It’s a slanted doorway that just seems to lead into the ground. Ultrasounds confirm it doesn’t actually lead anywhere, which is really strange. On that note, ultrasounds also confirm that other parts of the city do have an underground network. So, we shouldn’t  jump to conclusions as we are just learning about this civilization, but a doorway that leads into directly into the ground at the center of the city is really unusual. Also, it makes sense that a city confined by the walls has to get creative when expanding, but why did these beings choose to build down when they could have built up?', 'story1');
INSERT INTO segment VALUES('segment8', 'politics', 15, 'While the city has massive walls protecting it from without, it’s unusual to see a city of this size that has walls protecting it from the outside, but no second set of walls on the inside. Back on earth, most cities that feel threatened enough to build a set of giant walls, and have the technological and economic acumen to do so, rarely build just the one set. Come to think of it, once a certain amount of technological sophistication is achieved civilizations on earth tended to forget about walls and go with less visible and less intrusive but more sophisticated means of defense such as radar. As intruders, we should definitely be careful. Let’s hope the walls are just symbolic.', 'story1');
INSERT INTO segment VALUES('segment9', 'politics', 20, 'Those on the team who would like to study more complex topics like politics and culture have submitted a request to start exploring beneath the city. Mostly, that’s because nobody has been able to find an entry-way towards the underground and so some are suggesting creating one ourselves. Unfortunately, it is still not obvious what exactly is a door in this place, and even then, the city is still without power. Right now, we’re stuck sightseeing on the surface where there are no advertisements, or graffiti, or any attempts at mass public communication. Until we start receiving decoded and translated data, our best chance to study this place’s social dynamics is to have access to the actual dwellings, above or below ground.P.S. It’s ironic to be lectured by engineers, who regularly learn about things by taking them apart, on the virtues of preserving the thing you are trying to understand.', 'story1');
INSERT INTO segment VALUES('segment10', 'politics', 25, 'Safety concerns are dominating the consideration for digging underground. While it appears that nobody else is here, we don’t know that to be true with 100% certainty. Even if that may be true, we also don’t know if the city is still capable of communicating or transmitting information to anyone else. If it is, our intrusion has the possibility of being interpreted as an act of aggression. Given the fortress-like structure of the city and the mounting evidence that this could be some kind of military or penal colony, then our actions also have the potential to be construed as a declaration of war on behalf of all of humanity. However, the city/fortress being entirely deserted is still the most likely scenario. Also, the possibility of a miscommunication with other intelligent life in their sovereign space and the danger that comes with that should have been considered begore embarking on the mission at all, as this possibility is always present when communicating with intelligent life. If the leadership really believed we were in any immediate danger the we should be given orders to leave. Hopefully, that won’t turn out to be the case.  ', 'story1');
INSERT INTO segment VALUES('segment11', 'technology', 5, 'We are inside the city’s walls now. We had to be airlifted into the center of the city because we couldn’t seem to find an entrance through the city’s enormous walls. Everything inside looks very advanced, though it’s hard to tell. We won’t know anything for sure until we bring objects back to the lab for analysis. Our instructions are to bring back anything that looks out of place so as to not upset evidence that may tell us how these beings lived. We have strict instructions, however, to not bring back any object that looks like an applicator, which means anything that looks like it’s meant to be pointed at something. Right now, we can’t tell the difference between a camera and a gun. As a safety rule: if it looks like it’s meant to be pointed at something then we should wait until we better understand this technology in general before we even begin to analyze it. ', 'story1');
INSERT INTO segment VALUES('segment12', 'technology', 10, 'Looks like binary is almost universal. Of what we’ve been able to bring back to the lab, most of what we’re studying operates on 1 or 0 transistors like on earth. There are some objects, however, that we can’t seem to make sense of but they do look like they would be useful. Case in point, the only thing we a screen that we brought back has a very parsimonious interior. It’s exciting to imagine what this advanced tech can teach us about computing, especially since it’s likely to be compatible with the ‘antiquated’ transistor technology from back home. On a similar note, we haven’t been able to find anything that resembles a car or a ship. It makes you wonder how they got in or out.', 'story1');
INSERT INTO segment VALUES('segment13', 'technology', 15, 'Carbon dating shows that all of the objects that appear advanced are somewhat young. The objects that still rely on transistors, however, vary greatly in age. More precisely, the amount of C14 in the atmosphere is fairly high, but the older bits of tech have an unusually low C14 to C12 ratio. So, either the tech did not come from this planet with this atmosphere, or it was built a very long time ago, assuming atmospheres take a very long time to change. Is it possible that this civilization is like us and encountered an advanced civilization in the past? The tech being extraterrestrial would explain the substantial difference in C14 ratios. Of course, extinction via environmental destruction is still a possibility, but that would not be a very satisfying explanation as to why this is the only place left.', 'story1');
INSERT INTO segment VALUES('segment14', 'technology', 20, 'A few things are holding up our progress in analyzing the tech. We’re trying to first analyze the tech in some theoretically noninvasive way before trying taking it apart or physically altering it. We’ve tried millimeter scanners, electron spectroscopy, LiDAR, and hyperspectral imaging, but all of them are indicating that these objects are not even there. Billions of dollars in scanning and detection technology can’t seem to outdo the human eye, at least in proving that these objects exist. Additionally, everything in the city from the tallest buildings to hand held devices is covered in the same material. It’s possible the entire city is resistant to being electronically detected, which is all the more baffling given the lack of other signs of intelligent life on this planet. After all, why hide from electronic detection if there are no other electronics anywhere on the planet?', 'story1');
INSERT INTO segment VALUES('segment15', 'technology', 25, 'Thinking about it some more, if the city was designed to be undetectable by electronic scanning, then the ultrasounds are not going to be reliable. Ultrasounds have only been able to detect some empty spaces beneath the city that are very unlikely to be natural.  We have no way of knowing how much more of the city is below ground electronically. We would have to go below ground in person to know for sure. While many feel it would be prudent to wait until we understand the technology better, others are getting impatient with the slow progress in decoding the beings’ technology. The pretext of safety may be phony, however.  Having learned of the possibility of an underground component for any city, it’s logical that we intend to eventually explore the underground to learn as much as we can. It’s a question of when. So, it makes one wonder if the mission objective has changed now that we have found technology that can be incorporated into our  military back home.', 'story1');