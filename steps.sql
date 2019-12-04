/*Written by Tiansheng Sun */

/*create a new view that contains all the hotels and guest houses in Dar es Salaam as dots*/
CREATE TABLE hotelindar AS
SELECT osm_id, way, tourism
FROM planet_osm_point as a
where a.tourism = 'hotel' OR a.tourism = 'guest_house'

/* add a column to hotelindar, which contains the subward in which each hotel is located */
ALTER TABLE hotelindar ADD COLUMN fid float8

/* update the new field */
UPDATE hotelindar
SET fid = a.fid
FROM subwards as a
WHERE st_intersects(hotelindar.way, a.geom)

/*find the number of hotels in each subward*/
CREATE TABLE hotel_count as 
SELECT fid, count(distinct way)
FROM hotelindar
GROUP BY fid

/* add the information about the number of hotels to subward feature and create a new table */
CREATE TABLE subward_detail as 
Select subwards.fid, geom, count
from subwards left join hotel_count
on hotel_count.fid = subwards.fid

/* set 0 to subwards with no hotels */
UPDATE subward_detail
SET count = 0
WHERE count IS NULL

/* add a column to subward_detail */
ALTER TABLE subward_detail ADD COLUMN area real;
UPDATE subward_detail SET area = ST_Area(geom::geography) /100000

/* update the new field as the number of density of hotels of each subward */
ALTER TABLE subward_detail ADD COLUMN hotel_density real;
UPDATE subward_detail SET hotel_density = count / area
WHERE count > 0

/* update the new field to zero if there is no hotel */
UPDATE subward_detail
SET hotel_density = 0
WHERE hotel_density IS NULL

/* calculate the number of restaurants within 500 meters for each hotel and create a new view */
CREATE VIEW restaurant_accessibility as
Select a.osm_id, a.way, SUM(CASE WHEN b.amenity = 'restaurant' and ST_intersects(st_transform(b.way, 32727), (ST_BUFFER(st_transform(a.way, 32727),  500))) then 1 else 0 end)
from hotelindar as a left join planet_osm_point as b
on b.amenity = 'restaurant' and ST_intersects(st_transform(a.way, 32727), (ST_BUFFER(st_transform(b.way, 32727),  500)))
group by a.osm_id, a.way


































































ALTER TABLE planet_osm_point ADD COLUMN hotel_accessibility int;
UPDATE planet_osm_point SET hotel_accessibility = 1
WHERE amenity = 'restaurant' and ST_intersects(st_transform(way, 32727), (SELECT ST_BUFFER(st_transform(ST_Multi(ST_Union(way)), 32727),  500) FROM hotelindar))


Select a.osm_id, a.way, SUM(b.hotel_accessibility)
from hotelindar as a left join planet_osm_point as b
on b.amenity = 'restaurant'
group by a.osm_id, a.way
LIMIT 20


ALTER TABLE hotelindar ADD COLUMN restaurants int;
BEGIN
    FOR rec IN SELECT *
          FROM hotelindar
          LIMIT 20
    LOOP 
		FOR rec2 IN SELECT *
				FROM planet_osm_point 
		update hotelindar
            set restaurants = 
        where ST_intersects(st_transform(rec2, 32727), (ST_BUFFER(st_transform(rec, 32727),  500)))
    END LOOP
END





SELECT *
FROM planet_osm_point
where ST_Within(way, (SELECT ST_BUFFER(way, 1000) FROM hotelindar))
and amenity = 'restaurant'
LIMIT 100









SELECT a.tourism, b.fid,  
CASE
WHEN st_coveredby(a.way, b.geom)
THEN st_multi(a.way)
ELSE
st_multi(st_intersection(a.way, b.geom)) END AS geom
FROM planet_osm_point AS a INNER JOIN subwards AS b
ON (st_intersects(a.way, b.geom) AND NOT st_touches(a.way, b.geom))
WHERE a.tourism = 'hotel' OR a.tourism = 'guest_house'

ALTER TABLE subwards ADD COLUMN hotel_count int

ALTER TABLE subwards
DROP COLUMN hotel_count

UPDATE subwards
SET hotel_count = (
CASE when hotel_count.count > 0 then hotel_count.count 
else 0
end
)
FROM hotel_count
WHERE subwards.fid = hotel_count.fid
