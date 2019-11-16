# Vulnerability of Malawi: looking into uncertainty and reproducibility of geographic research
### Introduction
Vulnerability analysis has becoming a very important topic in geographical analysis, and can be important in developing countries, including those in sub-Saharan Africa. Malcomb et al.(2014) offered a way to conduct vulnerability modeling analysis in Malawi, which provides a framework to determine what drives vulnerability at a household level, maps the regions of Malawi that are under the highest level of vulnerability, and they believe can assist other vulnerable developing countries in sub-Saharan Africa. The project aims to replicate the map of vulnerability to climate change in Malawi and try to understand the uncertainty and reproducitility of vulnerability geographical research, a topic that has becoming increasingly important in critical GIS and geography.

### Reference article 
The analysis for activity is based on the following reference article: 

Malcomb, D. W., E. A. Weaver, and A. R. Krakowka. 2014. Vulnerability modeling for sub-Saharan Africa: 
An operationalized approach in Malawi. *Applied Geography, 48:17-30.*

### Methodology
The methodology that we used for this project is based on the methodology that Malcomb et al. used for their analysis. For a complete background of Malcomb et al.'s methodology, you can read through the methodology section of their paper. 

The foundation for Malcomb et al.'s vulnerability model was the socioeconomic data provided through DHS, which was comprised based upon over 38,500 household surveys in Malawi from 2004 to 2010, offering a complex set of variables that correspond to access and assets, such as the number of livestock, arable land, access to technology sharing, ability to meet food needs, etc. With the data, Malcomb et al. selected the most important indicators and weighted the variables appropriately with expert opinion, and came up with the hierarchy and weighting of the eighteen evidence-based indicators for their analysis of vulnerability in Malawi. Each individual indicator is normalized between zero and five, with zero representing the worst condition for a household and five being the best.
![Methodology](https://user-images.githubusercontent.com/25497706/68998207-70863800-087d-11ea-905b-a939bb4eac95.PNG)

Due to a lack of data of the livelihood sensibility category, we were able to only replicate 80% of the map of vulnerability to climate change in Malawi. We will conduct our vulnerability analysis using QGIS with Grass and PostGRESQL. Because of a data accessbility issue,the entire class has decided to do the Adaptive Capacity part together under professor's account with each of us providing solutions and SQL quries to the analysis. The data for physical exposure part: global flood risk layer and Malawi drought physical exposure layer, can be easily downloaded. Therefore, I have done the second part on my own, classifying the to a range of 0 to 5 and combining results from the two exposure layers with the average resilience scores from the Adaptive Capacity part together based on the weight to produce the final map product.

### Data Source
Data is collected from multiple sources:
1. The global flood risk layer from UNEP Global Risk Map. 
2. The Malawi drought physical exposure layer from UNEP Global Risk Map. 
3. DHS Cluster Points, with info here: https://dhsprogram.com/What-We-Do/GPS-Data-Collection.cfm.
4. DHS Survey Data.  
5. FEWSnet Livelihood Zones: https://fews.net/fews-data/335.

### Results
### Discussion
p
