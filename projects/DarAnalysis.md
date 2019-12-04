# Hotel distribution and its accessibility to restaurants in Dar es Salaam, Tanzania
**Hamjambo!**
As the largest city in Tanzania, Dar es Salaam is one of the most dynamic cities in East Africa. Although it is not particularly famous for
tourism, it still attracts people to the city who either do business here or use it as a jumping board to famous tourist attractions all over
the country, such as the Old Town of Zanzibar. Therefore, there is some demand for hotels in the city. Foreign hotel guests, moreover, who are 
not especially familiar with the city, are also more likely to eat in restaurants near hotels. In this activity, I plan to look at the 
distribution of hotels in the subwards of Dar es Salaam, and the number of restaurants each hotel is accessible to within 500 meters. What are
some of the spatial patterns?

### Data and Tools
The data used for this activity is from **OpenStreetMap** and **Resilience Academy**. Dar es Salaam is one of the most mapped cities in OpenStreetMap,
and most of the data used in this activity is from OpenStreetMap. Additional information of the subwards of Tanzania is also collected from
Resilience Academy.

The tool used for this activity is PostGIS in QGIS software. First of all, the OpenStreetMap database was downloaded from the [website](https://www.openstreetmap.org)
and stored as an **.osm file**. Then, I ran the [convertOSM.bat](osm_script/convertOSM.bat) script that parsed through the dsm_om.osm file and load relevant data into my 
PostGIS database. The data that I used is the planet_osm_point data, which contains points with information of their geometry and information.
Now, the OpenStreetMap data is ready to use!

Moreover, the [Resilience Academy](https://geonode.resilienceacademy.ac.tz/geoserver/ows) data was loaded in the WFS feature section of QGIS. From there,
the subward layer can be added to QGIS and my PostGIS database. 

### Data Analysis
[Here](tianshengs.github.io/SQL_quries/dar.sql) are the steps for my spatial analysis.
```
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
```  

### Result
I created a [Leaflet map](dsmmap/index.html) to visualize the final product of my analysis. The darker the subward, the higher its density
of hotel is. The darker and larger each dot (representing hotel) is, the more restaurants are within 500 meters. You can check and uncheck
each layer, and also compare my result with the OpenStreetMap base map underneath.

First of all, many hotels are located in the city center and along major roads. As we can see, the city center has a relatively high density
of hotels, although the Kariakoo district next to it has a higher density.Moreover, many hotels are also clustered along Morogoro road and Uhuru Street.
The CBD and Embassy district to the east of the city center, on the other hand, has much fewer hotels. 

Moreover, hotels located in subwards with higher density of hotels (city center, Kariakoo and along Morogoro Road) also get access to more restaurants
than the ones in other subwards. Although Kariakoo has the higher density of hotels compared to the city center, the hotels located in the city center has much higher 
access to restaurants. 

### Some Thoughts
For the analysis, I looked for both hotels and guest houses in the OpenStreetMap layer. Yet, hotels and guest houses may produce different results. For example, many of the hotels with no access to restaurants within 500 meters in subwards with a low density may indeed be guest houses or bed-and-breakfast. 

Moreover, the dataset seems to include mostly information of individual restaurants. Yet, we should be aware that many hotel guests eat in hotels and guest houses. For example, one of the grandest restaurants *Hyatt Regency Dar es Salaam, The Kilimanjaro* located in the CBD district of Dar es Salaam, has zero access to restaurants within 500 meters. However, the hotel should definitely have advanced restaurants and dining services for hotel guests. 

#### [Back to Main Page](index.md)
