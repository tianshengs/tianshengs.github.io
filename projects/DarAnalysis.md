# Hotel distribution and its accessibility to restaurants in Dar es Salaam, Tanzania
### Introduction
**Hamjambo! Karibuni Dar es Salaam.**
As the largest city in Tanzania, Dar es Salaam is one of the most dynamic cities in East Africa. Although it is not particularly famous for
tourism, it still attracts people to the city who either do business here or use it as a jumping board to famous tourist attractions all over
the country, such as the Old Town of Zanzibar. Therefore, there is some demand for hotels in the city. Foreign hotel guests, moreover, who are 
not especially familiar with the city, are also more likely to eat in restaurants near hotels. In this activity, I plan to look at the 
distribution of hotels in the subwards of Dar es Salaam, and the number of restaurants each hotel is accessible to within 500 meters. What are
some of the spatial patterns?

### Data and Tools
The data used for this activity are from **OpenStreetMap** and **Resilience Academy**. Dar es Salaam is one of the most mapped cities in OpenStreetMap,
and most of the data used in this activity is from OpenStreetMap. Additional information of the subwards of Dar es Salaam is collected from
Resilience Academy. 

Here are the specific data shpafiles that I used for my analysis:
1. planet_osm from **OpenStreetMap**
2. subwards from **Resilience Academy**

The tool used for this activity is PostGIS in QGIS software. First of all, the OpenStreetMap database was downloaded from the [website](https://www.openstreetmap.org)
and stored as an `.osm file`. Then, I ran the [`convertOSM.bat`](../osm_script/convertOSM.bat) script that parsed through the dsm_om.osm file and load relevant data into my 
PostGIS database. The data that I used is the planet_osm_point data, which contains points with information of their geometry and information.
Now, the OpenStreetMap data is ready to use!

Moreover, the [Resilience Academy](https://geonode.resilienceacademy.ac.tz/) data was loaded in the WFS feature section of QGIS. From there,
the subward layer can be added to QGIS and my PostGIS database. 

### Method 
**a. Data Analysis**

I wrote [SQL codes](../queries/dar.sql) for my spatial analysis. Here are the specific steps:

  1. I selected all the points from `planet_osm_point` that are labelled as *"hotel"* or *"guest_house"* under the "tourism" column. These points are stored in a new table called **hotelindar**.
  1. I added a colulmn to the table **hotelindar** and updated the new field with the `subward` information in which each point is located.
  1. I calculated the number of hotels in each subward and store the information in a new table called **hotel_count**.
  1. I joined the number of hotels information with the `subward` feature and set 0 to subwards with no hotels or guesthouses and stored the joined table into a new table called **subward_detail**.
  1. I added a column in **subward_detail** in which area of each subward is calculated in square kilometers.
  1. I created a new field in **subward_detail** to store the hotel density of each subward.
  1. I calculated the number of restaurants within 500 meters for each hotel. The result is stored in a new view **restaurant_accessibility**.
  
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

/* create the new field as the number of density of hotels of each subward */
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

**b. Create a Leaflet Map**

Once I finished the data analysis step, I created a leaflet map to visualize the final product of my analysis. The two layers that I included for my final map are **subward_detail**, which shows the density of hotels in each subward as a polygon feature and **restaurant_accessibility**, which shows each hotel as a point feature. Before I exported a map to the internet, I did the following steps to the two layers in QGIS:

  1. I exported feature layers with minimum of attribute that I wanted to include as final result and symbolized points as simple marker circles for the ease of translating to Leaflet *circleMarker* symbols. For example, I only included the following columns for **subward_detail**:fid, count, area and hotel_density. I only included the following columns for **hotel accessibility**: sum.
  1. I included a base layer by using **QuickMapService** in QGIS to add thd **OpenStreetMap** layer.
  
Finally, I used the `QGIS2WEB` plugin and setted the exporter to Leaflet to create a leaflet. In the **Layers and Groups** tab settings, 
I unchecked **visible** option for the hotel_accessbility layer so that we can start with the layer being invisible until the user selects to look at it in the legend. I chose to check the **visible** option for the base map and **subward_detail** layer. Moreover, in the **Appearence** tab, I changed **Add layer list** to *expanded* to always list each layer and allow them to be turned on and off and **Template** to *full-screen* to create the map that fill the web broswer.I also customized **Scale/Zoom** by setting **Max zoom level** to 19 and **Min zoom level** to 6 and checking the **Restrict to extent** option to prevent the map from panning out of the bounds of the extent currently displayed in QGIS.

**c.Editing the Leaflet HTML page**

Finally, once the Leaflet had been downloaded, I modified the index.html file to change the symbology and content of my leaflet map. Specifically:
  1. Change the `map.attributioncontrol.SetPrefix` function to include my name and a link to my GitHub page. I also added appropriate credit for all layers.
  1. Changed the styles and names of each vector layer, pop-up content and legend to better reflect their meaning.
  1. Added a scale bar at the end of the document.
  1. Customized the initial map extent for a better initial map extent.

### Result
Here is the final [Leaflet map](../dsmmap/index.html) of the hotel accessibility of Dar es Salaam. The darker the subward, the higher its density
of hotel is. The darker and larger each dot (representing hotel) is, the more restaurants are within 500 meters. You can check and uncheck
each layer, and also compare my result with the OpenStreetMap base map underneath.

First of all, many hotels are located in the city center and along major roads. As we can see, the city center has a relatively high density
of hotels, although the Kariakoo district next to it has a higher density.Moreover, many hotels are also clustered along Morogoro road and Uhuru Street.
The CBD and Embassy district to the east of the city center, on the other hand, has much fewer hotels. 

Moreover, hotels located in subwards with higher density of hotels (city center, Kariakoo and along Morogoro Road) also get access to more restaurants
than the ones in other subwards. Although Kariakoo has the higher density of hotels compared to the city center, the hotels located in the city center has much higher 
access to restaurants. 

### Thoughts
For the analysis, I looked for both hotels and guest houses in the OpenStreetMap layer. Yet, hotels and guest houses may produce different results. For example, many of the hotels with no access to restaurants within 500 meters in subwards with a low density may indeed be guest houses or bed-and-breakfasts. 

Moreover, the dataset seems to include mostly information of individual restaurants. Yet, we should be aware that many hotel guests eat in hotels and guest houses. For example, one of the grandest hotels *Hyatt Regency Dar es Salaam, The Kilimanjaro* located in the CBD district of Dar es Salaam, has zero access to restaurants within 500 meters. However, the hotel should definitely have advanced restaurants and dining services for hotel guests. 

![Hyatt-Regency-Dar-es-Salaam-The-Kilimanjaro-P087-Exterior-Evening 16x9](https://user-images.githubusercontent.com/25497706/70330631-eb52cb00-180b-11ea-84a9-e88d03299288.jpg)
A picture of the grand Hyatt Regency Dar es Salaam, The Kilimanjaro

#### [Back to Main Page](../index.md)
