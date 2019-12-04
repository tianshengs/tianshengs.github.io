/*Tiansheng Sun Twitter Analysis*/

/*insert the spatial reference system needed for this analysis*/
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');

/*Create a point geometry for dorian twitter data*/
SELECT AddGeometryColumn ('public','dorian','geom',102004,'POINT',2, false);
update dorian set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);

/*Create a point geometry for all november twitter  data*/
SELECT AddGeometryColumn ('public','november','geom',102004,'POINT',2, false);
update november set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);

/*select only the counties that we are interested in looking*/
UPDATE counties SET geometry = st_transform(geometry, 102004);
select populate_geometry_columns('counties'::regclass);
DELETE FROM counties
WHERE statefp NOT IN ('54', '51', '50', '47', '45' ,'44', '42', '39', '37', '36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17', '13', '12', '11', '10', '09', '05', '01');

/*add which county each november post is located in*/
ALTER TABLE november ADD COLUMN geoid varchar(5);
UPDATE november SET geoid = a.geoid
FROM counties as a
WHERE st_intersects(geom, a.geometry);

/*get the total number of november post in each state*/
SELECT geoid, COUNT(geoid) FROM november GROUP BY geoid;

/*add which county each dorian post is located in*/
ALTER TABLE dorian ADD COLUMN geoid varchar(5);
UPDATE dorian SET geoid = a.geoid
FROM counties as a
WHERE st_intersects(geom, a.geometry);

/*get the total number of dorian post in each state*/
SELECT geoid, COUNT(geoid) FROM dorian GROUP BY geoid;

/*add the number of total number of november posts to each county*/
ALTER TABLE counties ADD COLUMN count int;
UPDATE counties SET count = 0;
UPDATE counties SET count = a.count
FROM (SELECT geoid, COUNT(geoid) as count FROM november GROUP BY geoid) AS a
where counties.geoid = a.geoid

/*add the number of total number of dorian posts to each county*/
ALTER TABLE counties ADD COLUMN count_dorian int;
UPDATE counties SET count_dorian = 0;
UPDATE counties SET count_dorian = a.count
FROM (SELECT geoid, COUNT(geoid) as count FROM dorian GROUP BY geoid) AS a
where counties.geoid = a.geoid

/*calculate the number of Dorian tweets per 10000 people*/
ALTER TABLE counties ADD COLUMN tweet_rate real;
UPDATE counties SET tweet_rate = count_dorian / pop * 10000.0

/*calculate the ndti (tweets about dorian - baselind november twitter activity)/(tweet about storm + baseline november twitter activity)*/
ALTER TABLE counties ADD COLUMN ndti real;
UPDATE counties SET ndti = 0.0;
UPDATE counties SET ndti = 1.0 * (count_dorian-count)/(count_dorian + count)
WHERE count_dorian > 0 or count > 0
