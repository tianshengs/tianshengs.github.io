# Vulnerability of Malawi: looking into uncertainty and reproducibility of geographic research
### Introduction
Vulnerability analysis has become a very important topic in geographical analysis, and can be important in developing countries, including those in sub-Saharan Africa. Malcomb et al. (2014) offered a way to conduct vulnerability modeling analysis in Malawi, which provides a framework to determine what drives vulnerability at a household level, maps the regions of Malawi that are under the highest level of vulnerability, and assists other vulnerable developing countries in sub-Saharan Africa. The project aims to replicate Malcomb et al.'s map of vulnerability to climate change in Malawi and try to understand the uncertainty and reproducitility of vulnerability geographical research, a topic that has becoming increasingly important in critical GIS and geography.

### Data Source

- The global flood risk layer from [UNEP Global Risk Map](https://preview.grid.unep.ch/index.php?) for risk to flooding events.
  We use the global flood risk layer instead the one specifically for Malawi because the one for Malawi contained errors and does not actually match up to where the country is. 
- The Malawi drought physical exposure layer from [UNEP Global Risk Map](https://preview.grid.unep.ch/index.php?preview=extract&cat=1&lang=eng) for estimated physical exposure to drought events.
- DHS Cluster Points from [the DHS website](https://www.dhsprogram.com/Data/).
- DHS Survey Data from [the DHS website](https://dhsprogram.com/What-We-Do/GPS-Data-Collection.cfm). 
- [FEWSnet Livelihood Zones](https://fews.net/fews-data/335).
- [Major Lakes, from OpenStreetMap via MASDAP](http://www.masdap.mw/layers/geonode:major_lakes). This layer is used for the final map to show the major lakes of Malawi.

The above data sources from multiple sources were used to reproduce Malcomb et al.'s map. However, the multiple data layers may be different from what Malcomb et al. used or reflect the data in different periods. For example, I used the global flood risk layer because Malcomb et al. mentioned so in the methodology part; however, he also used the word " phsyical exposure" frequently, and in fact "physical exposure" is another layer that UNEP Global Risk Map offers for flooding events. This can create confusing points in the actual data that he used for his research.

### Reference article 
The analysis for activity is based on the following reference article: 

Malcomb, D. W., Weaver, E. A., and Krakowka, A. R. (2014). Vulnerability modeling for sub-Saharan Africa: 
An operationalized approach in Malawi. *Applied Geography, 48:17-30.*

### Methodology
**a. Introduction**

The methodology that I used for this project is based on the methodology that Malcomb et al. used for their analysis. For a complete background of Malcomb et al.'s methodology, you can read through the methodology section of their paper. 

The foundation for Malcomb et al.'s vulnerability model was the socioeconomic data provided through DHS, which was comprised based upon over 38,500 household surveys in Malawi from 2004 to 2010, offering a complex set of variables that correspond to access and assets, such as the number of livestock, arable land, access to technology sharing, ability to meet food needs, etc. With the data, Malcomb et al. selected the most important indicators and weighted the variables appropriately with expert opinion, and came up with the hierarchy and weighting of the eighteen evidence-based indicators for their analysis of vulnerability in Malawi. Each individual indicator is normalized to a final score between zero and five, with zero representing the worst condition for a household and five being the best.

![Methodology](https://user-images.githubusercontent.com/25497706/68998207-70863800-087d-11ea-905b-a939bb4eac95.PNG)

**b. SQL for resilience scores**

Due to a lack of data of the livelihood sensitivity category, we were able to only replicate 80% of the map of vulnerability to climate change in Malawi. Because of a data accessbility issue, the entire class has decided to do the Adaptive Capacity part together under professor's account with each of us providing solutions and SQL quries to the analysis. Our initial approach of normalizing each individual indicator is to use `NTILE()` function in SQL quries. However, NTILE will break all rows into approximately equal groups and may assign rows with the same value into different quantile. Therefore, we converted all the values first to a percent rank, and then uses `NTILE()` to normalize the percentile rank value into zero to five. Finally, we have collectively calculated the adaptive capacity scores for each traditional authority of Malawi. A traditional authority with a higher score means a higher resilience. [Here](SQL_quries/vulnerability.sql) is the SQL code that we wrote collaboratively as a class.

**c. Model to create layers**

The shapefile layer with the calculated Adaptive Capacity score has an extent larger than the livelihood zones of Malawi. We also want to rasterize the shapefile layer in order to use it with global flood risk layer and Malawi drought physical exposure layer for our next step. Moreover, we also want to clip the flood risk layer and the drought physical exposure layer into the extent of our clipped Adaptive Capacity grid to get rid of the data for cells in which there is no data on the capacity layer. To do all the clipping process, we built a [model](model/vulnerability_final.model3) that takes in all the above layers and output the clipped Adaptive Capacity score layer, the rasterized Adaptive Capacity score layer, the clipped flood risk layer and the clipped drought physical exposure layer. I also added a parameter to the original model in which the user can input the cell size for the final results. I set the default resolution to be 5-minute resolution (0.08333333 decimal degrees), yet for my analysis, I used the 2.5-minute resolution (0.04166666 decimal degrees) to produce a result that more closely matches Malcomb et al.'s map.

**d. GRASS functions to reclassify drought layer**

Before I added all the scores together, I used the GRASS `r.Quantile` and `r.Recode` algorithms in QGIS 3.8.1 with GRASS 7.6.1 to reclassify the drought layer to a scale of 1 to 5. Remember that the two algorithms are GRASS fucntions and can *only* be used in QGIS with GRASS. 

The `r.Quantile` function calculates the quantile for an input layer and saves the result as a **.html** file. I setted the `Input raster layer` as the drought layer, and changed `Number of quantiles` to 5. It is important to open the `Advanced Parameters` and check the `Generate recode rules based on quantile-defined intervals`.

After running the function, I opened the **.html** file and saved it in this [**.txt file**](data/quantile.txt). I then ran the `r.recode` function with the `Input raster layer` being the drought layer and `File containing recode rules` as this **.txt file** and the raster layer has been reclassified into quantile classes 1-5. 

**e. Raster Calculator for final result**

Before calculating the final result, I noticed that the scores for the flood layer is from 0-4. Therefore, I first used raster calculator to change the classification of the flood layer from 0-4 to 1-5. 

Finally, for the final result, I used raster calculator to combine the final results into the final vulnerability map with the following query:

```
(2 - Adaptive Capacity) + Drought Exposure * 0.20 + Flood Risk * 0.20
```

Note that because a high score for capacity correlates to a low vulnerability, I inverted the score by subtracting it from its maximum possible score 2 (40% of 5).

### Result

![Malawi_resilience](https://user-images.githubusercontent.com/25497706/70582111-57745c80-1b87-11ea-8a02-7b465ca96d28.png)

![malawi_vulnerability_result](https://user-images.githubusercontent.com/25497706/69486831-160d4e80-0e1e-11ea-865c-f45c94e6de52.png)

### Discussion
My map shows a general South-North divide in Malawi, that Southern Malawi is much more vulnerable than Northern Malawi, and the Malawian Deep South and areas around the capital city of Lilongwe have the highest degree of vulnerability. Although this pattern and conclusion is quite similar to Malcomb et al.'s map, there are indeed some difference, and these questions have let me to question the reproducibility of this vulnerability approach. 

First of all, the map that Malcomb et al. made seems to have a much finer resolution. However, Malcomb et al. did not seem to specify what resolution they chose for their result. This lack of information has made me hard to match the exact resolution and detail his map shows. Indeed, choosing different resolution level is very important in geospatial research because it may give people completely different results. A map with a coarser resolution, for example, will blur the variances and details provided in a map with a finer resolution, yet these details may give us large implications.

Secondly, my map is different from Malcomb et al.'s map because of the lack of data. While trying to reproduce his map, we only found 80% of the original data, with the livelihood sensitivity data missing. The livelihood sensitivity data, however, consists of 20% of the final score and can significantly affect the final result. Lack of access to data is a common challenge to the reproducibility of researches in geography. One may choose to make a phone call to author to ask for data source or the author can explicitly state their data source and give it publicly. However, accessing data is never as easy as getting it. One should also understand the ethnical and privacy issue behind releasing data to the public. The data for this vulnerability research in Malawi, for example, contains data collected from conveys which contain personal and household details. Therefore, there should be some surveillance over the access to this data, and this may affect the reproducibility of the research.

Thirdly, Malcomb et al. did not provide a clear clarification in their method. They provided a very detailed picture of how the survey data was collected and how the scores are calculated based on what weight. However, they did not specify what specific method and functions they used to normalize data and calculate the final result. For example, we do not know how they assigned scores to a data category with binary values. Did they assign "Yes" to 5 and "No" as 1, or "Yes" to 3 and "No" to 2? Yet this difference can make a profound impact to the final result. Therefore, to improve the reproducility of their research, Malcomb et. al can provide more details about their specific approach, or can include their code as part of the paper.

Indeed, looking at Malcom et al.'s Malawi Composite Vulnerability Index map, I noticed that although the authors added a legend to their map, there are regions on the map that are mapped as entirely white that are not represented in the legend. According to my map, these regions seem to be areas with no data, yet they are not marked as *Regions with no data*. This is one evidence that the original map contains significant errors.

It is also important to consider the uncertainty of Malcomb et al.'s vulnerability model. Tate (2012) described three different types of vulnerability model structure: deductive, hierarchical and inductive. The vulnerability model that Malcomb et al.(2014) is clearly a hierarchical model because Malcomb et al. considered 18 factors that are then seperated into 3 groups that share the same underlying dimension of vulnerability. While the hierarchical model is the most accurate among the three, weighting is the main driver of uncertainty for Malcomb et al.(2014)'s model (Tate, 2012). Malomb et al.(2014) clearly stated all the vulnerabililty indexes, the data source and the weighting assigned to each index. However, how they assigned weight to each indicator is a a little confusing. Malcomb et al.(2014) said that weights were assigned based on the observations, fieldwork, interviews and literature reviews discussed in his paper, but I still find this argument very vague. Therefore, we do not know how the scale, location, variable selection and weighting of Malcomb et al.'s research will influence the final result.

Malcomb et al. also did not include a discussion section of potential errors or apply a sensitivity analysis mentioned by Tate (2012) in their paper, although there are some potential large source of errors that may affect their analysis and the correctness of their result. For example, in the survey for Adaptive Capacity, a 5km radius in a rural area or a 2km radius buffer was created around each survey point which was then randomly distributed in the buffer zone within the same *district* boundary. The assumption is that the household cluster information may represent the district. Malcomb et al., however, analyzed the vulnerability of each traditional authorities of Malawi, a level of political divisions that is smaller than districts. This means that household survey points may be assigned to different traditional authorities, which creates uncertainty in their result.

The lack of a methodological attention to the weighting in Malcomb et al.'s paper challenges the replicability of their research. Should we use the same weights for a different weight in another region, say, Kenya or Senegal? Since the observations, fieldwork, interviews, and literature review for different places will all be completely different, I think the answer should be no. However, the fact Malcomb et al. did not provide a systematic, quantitative methodology means that it is extremely hard for future researchers to specify weights based on Malcomb et al. (2014)'s standards. Therefore, the uncertainty over weighting may mean that the research isn't completely replicable.

Moreover, the same index can produce distinct patterns of vulnerability at different scales (Tate, 2012). For Malawi, Malcomb et al (2014) analyzed the vulnerability in the level of traditional authorities of Malawi. However, traditional authority is only a Malawian thing, and if we conduct vulnerability in another country, then the size of districts and scale of measurement may be different from that of Malawi's. Therefore, even if we can use the same indexes for a different place, we cannot simply compare the result from the new region with the one from Malawi. 

**Reference**:

Tate, E. (2012). Social vulnerability indices: a comparative assessment using uncertainty and sensitivity analysis. *Natural Hazards, 63(2), 325-347.*

#### [Back to Main Page](index.md)
