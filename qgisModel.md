# Lab1: QGIS Modeling
In the first lab, I created a model to calculate the direction and distance from a point. The user can define a city center as a point or selected features, from which a point with the medium coordinates of the centroids of all selected features is calculated. Finally, the direction and distance from the city center point to the centroid of each feature in the shapefile is calculated with new fields in the attribute table (distance and direction) of the output. Finally, I created a documentation for the model that I created. The [Here](distance_from_point.model3) is my model.

During the second week, I modified and updated the model by doing the following:
- Add a Help webpage to my model.
- Use CASE to classify the direction data into N, E, S, W.
- Use Execute SQL to calculate distance.
- Apply the transform function of SQL to calculate azimuth.
The problem that I faced is that the Execute SQL only worked with a single point, but not with selected feature data. Therefore, to get a single point from selected features, the user may now need to just run centroids and mean coordinates separately before they use my Model to calculate. 

After updating the model, I downloaded the census-tract level shapefile of Puerto Rico from the [United States Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html) and information of the Hispanic or Latino origin by race per census tract in Puerto Rico from [American FactFinder](https://factfinder.census.gov/faces/nav/jsf/pages/index.xhtml). I plan to focus my study area to the San Juan metropolitan area, calculate the direction and distance of all census tracts from the city center (which is a centroid point that I calculated seperately), and see how the percentage of Hispanic people changes by distance or direction from central San Juan. 

This is a [graph] that I created using Data Plotly that illustrates the relationship between percentage of Hispanic people and distance from central San Juan. As we can see from the graph, while a majority of the census tracts have over 95% of Hispanic population, the few census tracts close to San Juan has slightly more non-Hispanic population. In central San Juan, the percentage of Hispanic people is only around 67%.

This is a graph that I created using Data Plotly that illustrates the relationship between percentage of Hispanic people and direction from central San Juan. Because central San Juan is located on a small island in the Northern coast of Puerto Rico, almost all of the census tracts are located to the south and east of central San Juan. Most of the census tracts to the South and Southeast has over 95% of Hispanic population, while a few coastal census tracts to the east of San Juan have a slightly lower percentage. 


#### [Back to Main Page](index.md)
