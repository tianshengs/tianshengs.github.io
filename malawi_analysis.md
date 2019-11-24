# Vulnerability of Malawi: looking into uncertainty and reproducibility of geographic research
### Introduction
Vulnerability analysis has become a very important topic in geographical analysis, and can be important in developing countries, including those in sub-Saharan Africa. Malcomb et al.(2014) offered a way to conduct vulnerability modeling analysis in Malawi, which provides a framework to determine what drives vulnerability at a household level, maps the regions of Malawi that are under the highest level of vulnerability, and assists other vulnerable developing countries in sub-Saharan Africa. The project aims to replicate the map of vulnerability to climate change in Malawi and try to understand the uncertainty and reproducitility of vulnerability geographical research, a topic that has becoming increasingly important in critical GIS and geography.

### Data Source
Data is collected from multiple sources:
1. The global flood risk layer from UNEP Global Risk Map. 
2. The Malawi drought physical exposure layer from UNEP Global Risk Map. 
3. DHS Cluster Points, with info here: https://dhsprogram.com/What-We-Do/GPS-Data-Collection.cfm.
4. DHS Survey Data.  
5. FEWSnet Livelihood Zones: https://fews.net/fews-data/335.
6. Major Lakes, from OpenStreetMap via MASDAP: http://www.masdap.mw/layers/geonode:major_lakes.

### Reference article 
The analysis for activity is based on the following reference article: 

Malcomb, D. W., Weaver, E. A., and Krakowka, A. R. (2014). Vulnerability modeling for sub-Saharan Africa: 
An operationalized approach in Malawi. *Applied Geography, 48:17-30.*

### Methodology
The methodology that I used for this project is based on the methodology that Malcomb et al. used for their analysis. For a complete background of Malcomb et al.'s methodology, you can read through the methodology section of their paper. 

The foundation for Malcomb et al.'s vulnerability model was the socioeconomic data provided through DHS, which was comprised based upon over 38,500 household surveys in Malawi from 2004 to 2010, offering a complex set of variables that correspond to access and assets, such as the number of livestock, arable land, access to technology sharing, ability to meet food needs, etc. With the data, Malcomb et al. selected the most important indicators and weighted the variables appropriately with expert opinion, and came up with the hierarchy and weighting of the eighteen evidence-based indicators for their analysis of vulnerability in Malawi. Each individual indicator is normalized to a final score between zero and five, with zero representing the worst condition for a household and five being the best.
![Methodology](https://user-images.githubusercontent.com/25497706/68998207-70863800-087d-11ea-905b-a939bb4eac95.PNG)

Due to a lack of data of the livelihood sensibility category, we were able to only replicate 80% of the map of vulnerability to climate change in Malawi. Because of a data accessbility issue, the entire class has decided to do the Adaptive Capacity part together under professor's account with each of us providing solutions and SQL quries to the analysis. Our initial approach of normalizing each individual indicator is to use NTILE() function in SQL quries. However, NTILE will break all rows into approximately equal groups and may assign rows with the same value into different quantile. Therefore, we converted all the values first to a percent rank, and then uses NTILE() to normalize the percentile rank value into zero to five. Finally, we have collectively calculated the adaptive capacity scores for each traditional authority of Malawi. A traditional authority with a higher score means a higher resilience.

The shapefile layer with the calculated Adaptive Capacity score has an extent larger than the livelihood zones of Malawi. We also want to rasterize the shapefile layer in order to use it with global flood risk layer and Malawi drought physical exposure layer for our next step. Moreover, we also want to clip the flood risk layer and the drought physical exposure layer into the extent of our clipped Adaptive Capacity grid to get rid of the data for cells in which there is no data on the capacity layer. To do all the clipping process, we built a [model](model/vulnerability_final.model3) that takes in all the above layers and output the clipped Adaptive Capacity score layer, the rasterized Adaptive Capacity score layer, the clipped flood risk layer and the clipped drought physical exposure layer. I also added a parameter to the original model in which the user can input the cell size for the final results. I set the default resolution to be 5-minute resolution (0.08333333 decimal degrees), yet for my analysis, I used the 2.5-minute resolution (0.04166666 decimal degrees) to produce a result more closely match Malcomb et al.'s map.

Before I added all the scores together, I used the r.Quantile and r.Recode algorithms in QGIS to reclassify the drought layer to a scale of 1 to 5. I also used raster calculator to change the classification of the flood layer from 0-4 to 1-5. Finally, I used raster calculator to combine the final results into the final vulnerability map. Because a high score for capacity correlates to a low vulnerability, I inverted the score by subtracting it from its maximum possible score 2 (40% of 5).

### Result
![malawi_vulnerability_result](https://user-images.githubusercontent.com/25497706/69486831-160d4e80-0e1e-11ea-865c-f45c94e6de52.png)

### Discussion
