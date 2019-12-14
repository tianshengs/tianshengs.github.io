# Christianity in Indonesia: A D3.js visualization

## Introduction
With the advance of open source technology, the discipline of cartography has also been rapidly developing and changing. For [Project 3](DarAnalysis.md), for example, I created a [Leaflet map](dsmmap/index.html) to visualize the number of hotels in each subwards of Dar es Salaam, Tanzania and the number of restaurants each hotel is access to within 500 meters. While geographers can use QGIS to easily create choropleth maps, such web-based maps can show different levels of details and information with interactions, custom tooltips, or Zoom that traditional maps are not able to show. Besides Leaflet, D3.js is a powerful open source Javascript library that can also be used to create interactive maps. For this project, I self-taught how to create an interactive map of the percentage of Christian population in each Indonesian province using the D3.js library. 

## Study Area
![sumatra-toba-02](https://user-images.githubusercontent.com/25497706/70854298-cef80380-1e87-11ea-8c08-d9c4785ec709.jpg)
The Toba Lake, where the Christian Batak people live

With an area of over 1.9 million square kilometers and a population of over 267 million, Indonesia is the largest country in Southeast Asia and the fourth most populated country in the world. With 88% of the population Muslims, Indonsia also has the world's largest Muslim community. However, Christianity, the second largest religion of the country, also played an important role in Indonesia. Moreover, as a country with a variety of different ethnic groups, religious belief, such as Christianity, is closely tied to each ethnic group's cultural identity. Certain ethnic groups such as the Toraja people in Sulawesi and the Toba Batak people in Northern Sumatra remain Chirstians in the seas of an Islam majority. Therefore, an understanding of the distribution of Christianity population can be important for us to learn about the compositions and regional variances of Indonesian society. 

## Tool
- `QGIS 3.8.1` was used to preprocess the shapefile data. 
- `Excel` was used to calculate the percentage of Christians in each province.
- `D3.js version 5` was used to make the web-based map. To use D3.js version 5, include the following script in the **.html** file of the map:
  ```
  <script type="text/javascript" src="https://d3js.org/d3.v5.js"></script>
  ```

  Additionally, I also saved a local version of the script so that I can use it in an offline environment. To do so, Type in       `https://d3js.org/d3.v5.min.js` in the browser and save all the contents in an **Javascript** file `d3.v5.js`. Then, in the main **.html** file, include the following script to use this local version of D3.js:
    ```
    <script type="text/javascript" src="d3.v5.js"></script>
    ```
    
## Data
I downloaded the following data for my analysis:
- `States and Province` (**Large scale data**, 1:10m) shapefile from [Natural Earth](https://www.naturalearthdata.com/downloads/10m-cultural-vectors/)

  Before using the shapefile for visualization, I processed the shapefile data by doing the following steps in QGIS 3.8.1:
  - The data that I downloaded from Natural Earth contains the provinces and states of all countries. Since I am only interested in the Indonesian provinces, I used the `Select by Attribute` tool by setting attribute `admin = Indonesia` to select only Indonesian provinces.
  - The shapefile contains columns that shows province names in various languages. For my purpose, I used the row `name_id` to match the Indonesian names with those listed on the `.csv` file. However, the province names for "Jakarta", "Jogjakarta" and"Bangka-Belitung" are different from that in the `.csv` file. Therefore, I changed these names in shapefile to "Daerah Khusus Ibukota Jakarta", "Kepulauan Bangka Belitung" and "Yogyakarta" as listed in the `.csv` file.
  - To use shapefiles with D3.js library, I finally extract the data into the format of `geojson`. I extracted the shapefile as a `geojson` from QGIS. 
  
- `Population by Religion within each province` (2010 Census data) csv file from [Badan Pusat Statistik](https://sp2010.bps.go.id/index.php/site/tabel?tid=321&wid=0)

  Note that although the website contains a table that shows the percentage of population by religion in each province, I could only download the csv file of the total number of population by religion from the website. Therefore, I later calculated the percentage of Christians in each province by hand in `Excel` before using it for visualization.
  
You can download this [file](https://github.com/tianshengs/tianshengs.github.io/files/3964368/Data_Used.zip) to view the original data and processed data that I used for this project. Inside the zipped file:
- `data` folder contains the original census data
- `ne_10m_admin_1_states_provinces` folder contains the original shapefile data
- `indonesia_province.geojson` is the final geojson file used for visualization
- `religion.csv` is the processed census data
  
## Tutorial and Reference

Many thanks the various tutorials and map examples that I have referenced to learn D3.js and create my map:

- [D3.js Essential Training for Data Scientists](https://www.linkedin.com/learning/d3-js-essential-training-for-data-scientists): an online course which is a wonderful easy introduction to the world of D3.js offered by Emma Saunders on LinkedIn;
- [Making a Map in D3.js v.5](http://datawanderings.com/2018/10/28/making-a-map-in-d3-js-v-5/): An easy introduction by Eve the Analyst into making a map using D3.js version 5;
- [Adding tooltips to a d3.js graph](http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html): A tutorial offered by Malcolm Maclean about how to add tooltips to a D3.js graph
- [Basic US State map](http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922) by Michelle Chandra;
- [Responsive interactive D3.js map](https://bl.ocks.org/andybarefoot/765c937c8599ef540e1e0b394ca89dc5) by Andy Barefoot;
- [Donut Multiples](https://bl.ocks.org/mbostock/3888852) by Mike Bostock.

## Steps for D3.js Visualization
  
  **a.
