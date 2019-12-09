# QGIS Modeling : a use case of San Juan, Puerto Rico

### Introduction

Measuring distance and direction is a common theme in GIS analysis. The concept of distance and direction, moreover, can be especially helpful for us to understand the organization of urban landscapes ([learn more](https://transportgeography.org/?page_id=4613)). While one can easily use GIS tools in ArcGIS to calculate the direction and distance from a point, with the advance of open source technologies, one can create a self-defined model to 
calculate the direction and distance from city center. For this project, I have created my own direction and distance calculator model. The model is then used to analyze the percentage of Hispanic people in San Juan metropolitan area of Puerto Rico. 
This is my introduction into open source GIS and the use of QGIS for GIS analysis. 

### Study Area

![lede puerto-rico-1](https://user-images.githubusercontent.com/25497706/70465955-151c2400-1a90-11ea-9f7f-ded36b96ff17.jpg)

San Juan is the largest city of Puerto Rico. Located in the North coast of Peurto Rico, it is a lovely old city with around 400,000 people and 2 million in its metropolitan area. Although the population of Puerto Rico is highly hispanic, we might expect to see some more diversity in this large metropolitan city. Specifically, it is interesting to see how the percentage of Hispanic people changes by distance or direction from central San Juan. 

### Data

I downloaded the **Census Tracts** shapefile and **County Within Urban Area** shapefile of Puerto Rico from the [United States Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html) and information of the Hispanic or Latino origin by race per census tract in Puerto Rico from [American FactFinder](https://factfinder.census.gov/faces/nav/jsf/pages/index.xhtml). The **County Within Urban Area** shapefile is used to crop out the San Juan study area from the **Census Tracts8* shapefile.

Here is the [geopackage](data/san_juan_analysis.gpkg) of data for the case study, including the original data that I downloaded and the shapefiles that I created through the process.

### Models and Method

**a. creating model using field calculator to calculate distance and direction**

[Here](model/distance_from_point.model3) is my initial model using field calculator to calculate distance and direction. The user can define a city center as a point or selected features, from which a point with the medium coordinates of the centroids of all selected features can be calculated. Finally, the direction and distance from the city center point to the centroid of each feature in the shapefile is calculated with new fields in the attribute table (distance and direction) of the output. Finally, I created a documentation for the model that I created. 

![initial](https://user-images.githubusercontent.com/25497706/70471759-d7bd9380-1a9b-11ea-8ea4-f8ab4796f784.PNG)

This is the specific field calculator query I used to calculate distance:
```
distance(centroid($geometry), 
make_point(  @Mean_coordinate_s__OUTPUT_maxx,  @Mean_coordinate_s__OUTPUT_maxy   ))
```

This is the specific field calculator query I used to calculate direction:
```
degrees( azimuth(  make_point(  @Mean_coordinate_s__OUTPUT_maxx,  @Mean_coordinate_s__OUTPUT_maxy ), centroid($geometry)))
```

**b.Update the old model with SQL quries** 

Then, I modified and updated the [model](model/new_distance_from_point.model3) by doing the following:

- Add a Help webpage to my model.

  The "Documentation help URL" is especially helpful, which directed the users to my Github page. I also added one for my original model.

- Use Execute SQL to calculate distance.
  ```
  SELECT*, st_distance(centroid(st_transform(geometry, 4326)), (Select st_transform(geometry, 4326) from input1), TRUE) as  DistSQL
  FROM input2
  ```

- Use `CASE` statement to classify the direction data into N, E, S, W.
The `CASE` statement can be helpful to calculate fields based on a set of one or more conditions. For my model, I used the `CASE` statement to classify the direction data into N, E, S, W based on the direction of the data: 
  ```
  CASE
  WHEN attribute(concat(@fieldname, 'Dir')) >= 225 AND attribute(concat(@fieldname, 'Dir')) < 315 THEN 'W'
  WHEN attribute(concat(@fieldname, 'Dir')) >=135 AND attribute(concat(@fieldname, 'Dir')) < 225 THEN 'S'
  WHEN attribute(concat(@fieldname, 'Dir')) >= 45 AND attribute(concat(@fieldname, 'Dir')) < 135 THEN 'E'
  ELSE 'N'
  END
  ```

- Apply the `transform` function of SQL to calculate azimuth while transforming it to the World Mercator projection (EPSG:54004).
  ```
  degrees( azimuth( 

  transform(
  make_point(@citycenter2_maxx ,  @citycenter2_maxy  ), 
  layer_property(@citycenter2 ,'crs'), 
  'EPSG:54004'
  ), 

  centroid(
  transform(
  $geometry, 
  layer_property(@inputfeatures, 'crs'),
  'EPSG:54004'))

  ))
  ```

The problem that I faced is that the Execute SQL only worked with a single point, but not with selected feature data. Therefore, to get a single point from selected features, the user may now need to just run centroids and mean coordinates separately before they use my Model to calculate. 


After creating the model, I opened QGIS 3.8 to do the following:

- Added the the Hispanic or Latino origin by race per census tract in Puerto Rico CSV file into QGIS. `Layer->Add Layer->Add Delimited Text Layer` is the best way to add CSV files into QGIS because it tries to detect data types correctly rather than assuming everything is a text string. I imported the layer with no geometry as a comma-delimited file.

- Added the Census Tract shapefile and County within Urban Area shapefile of Puerto Rico into QGIS.

- Selected the San Juan Metropolitan Area from the Census Tract shapefile and Use the QGIS function `Select by Location` to crop out the census tracts located within San Juan Metropolitan Area for analysis.

  Here is the cropped study area:

  ![Captured](https://user-images.githubusercontent.com/25497706/70470143-67f9d980-1a98-11ea-87e9-79fc40f902b6.PNG)

- Joined census data to Census Tract shapefile by opening the properties of the shapefile layer and using the Joins menu. To keep the data neet, I only selected the fields that I want to join: *latinx*, the column with the number of latino population and *total_pop* in each census tract, the column with the total number of population in the census tract. I joined the census data to Census Tract shapefile by the corresponding GEOID of each census tract, which is a unique feature in both files.
- Calculated the percentage of Latino population in each census tract and stored the value in a new column using `field calculator`. 
- Used the model to calculate the direction and distance from the center. I manually selected the three census tracts as city center for my analysis. 
- Created Data Plotly plots as HTML to show my results. Data Plotly plots are dynamic code written for the internet and can be created using a Plugin in QGIS. For my analysis of the percentage of Hispanic population in San Juan Metropolitan Area, I created a scatterplot of distance and polar plot of direction.


## Results
This is the choropleth map showing the percentage of Hispanic within each census tract:
![sanjuan](https://user-images.githubusercontent.com/25497706/70475798-536f0e80-1aa3-11ea-8253-59d5aae758f2.png)


This is a [graph](Plots/San_Juan_Plot_1.html) that I created using Data Plotly that illustrates the relationship between percentage of Hispanic people and distance from central San Juan. As we can see from the graph, while a majority of the census tracts have over 95% of Hispanic population, the few census tracts relatively closer to San Juan has slightly more non-Hispanic population. The city center, moreover, has only 68% of Hispanic population.

This is a [graph](Plots/San_Juan_Plot_2.html) that I created using Data Plotly that illustrates the relationship between percentage of Hispanic people and direction from central San Juan. Because central San Juan is located on a small island in the Northern coast of Puerto Rico, almost all of the other census tracts are located to the south and east of central San Juan. Most of the census tracts to the South and Southeast has over 95% of Hispanic population, while a few coastal census tracts to the east of San Juan have a slightly lower percentage. 

Overall, the analysis has shown that the although the majority of San Juan Metropolitan area is pretty homogeneous, the city center and a few census tracts along the coast stand out as regions with slightly more non-Hispanic population.

## Discussion: GIS: A tool or science?



#### [Back to Main Page](index.md)
