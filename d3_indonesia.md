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
- `D3.js version 5` was used to make the web-based map. To use D3.js version 5, include the following script in the `.html` file of the map:
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

#### 1. Setting up the map

First of all, I created a `.html` file and added the D3 Version 5 library into the `<head> section` of the html file. Then, I created `map.css` file, a file that stores the style formatting of various html elements, to which is pointed from the `<head> section` of the html file. 

I then created an `svg` element in the `<body> section` of the html file with width 1500 (pixel), height 700 (pixel) and background color with `"#c9e8fd"`. D3.js draws visualizations on a SVG image element. The SVG element is like a canvas to which you can create a map from. To learn more about SVG, refer to this [tutorial](https://www.tutorialspoint.com/d3js/d3js_introduction_to_svg.htm).

After that, I used `d3.geoPath` function creates a new geographic path generator and `d3.geoMercator()` to specify Mercator projection for the created geopath.To learn more about geoPath and projections, refer to this [d3geo Github page](https://github.com/d3/d3-geo). 

```
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Indonesia</title>
	<script type="text/javascript" src="https://d3js.org/d3.v5.js"></script>
	<link rel="stylesheet" type="text/css" href="map.css">
	<style></style>
</head>
<body>
    <script type="text/javascript">
	var width = 1500;
	var height = 700;
	
	//Referenced from: http://datawanderings.com/2018/10/28/making-a-map-in-d3-js-v-5/
	//create the svg element
	var svg = d3.select("body")
  		.append("svg").attr("preserveAspectRatio", "xMinYMin meet")
        	.attr("viewBox", "0 0 " + width + " " + height)
		.style("background","#c9e8fd")
        	.classed("svg-content", true);
		
	//define projection	
	var projection = d3.geoMercator().translate([width/2, height/2]).scale(1800).center([118,-3]);
	var path = d3.geoPath().projection(projection);
    </script>
</body>
```

#### 2.Loading data

After setting up the svg element and geoPath, I loaded the `geojson` and `csv` files into the file. 
The `geojson` file does not contain information of the percentage of Christian population of each province. To use the data for mapping purposes, I ran the following for loop to store the christian percentage data into a dictionary that stores `province name` as key and `percentage` as value. 

```
	var christian_dict = {};
	
	//get the percentage population data and store in christian_dict
	var christian = d3.csv("religion.csv").then(function(d){
		for (var i = 0; i < d.length; i++){
			christian_dict[d[i].Province] = [d[i].Percentage];
		}
	});
		
	//get the geojson file
	var indonesia = d3.json("indonesia_province.geojson");
```

#### 3. draw the map

**a. Introductory steps**

To append the geojson feature data onto the svg canvas, d3 v.5 allows users to create a promise, which according to this [tutorial](http://datawanderings.com/2018/08/15/d3-js-v5-promise-syntax-examples/) allows the functions to refer to later on and allows the dataset to be used before it is fully generated. The [`Promise.all()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all) function, moreover, returns a single promise when all the passed-in promises have been fulfilled. Although for my map, I am visualizing data only from the geojson file, I used this function to pass in data from the `geojson` dataset. 

Within the `Promise.all()` function, I appended the `geopath` to `svg` by setting data as each province feature of geojson. I have decided to divide all provinces into four groups anda fill each feature based on quantile of percentage value. I calculated the quantile values in `Excel` in my `.csv` file and got the following values:
```
quantile1 (25%) : 0.016655
quantile2 (50%) : 0.027265
quantile3 (75%) : 0.164778
```

Therefore, the four groups of my map are:
```
Group 1: provinces with less than 1.6655% of its population as Christian
Group 2: provinces with between 1.6655% and 2.7265% of its population as Christian
Group 3: provinces with between 2.7265% and 16.4778% of its population as Christian
Group 4: provinces with more than 16.4778% of its population as Christian
```

Accordingly, I have created a linear scale of colors each of which correspond to each group. Scale is a convenient way in D3 to map abstract data into visualization. Before D3 v.5, a linear scale is defined as d3.scale.linear() such as in my reference [Basic US State map](http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922) by Michelle Chandra. For D3 v.5, however, a linear scale is defined using `d3.scleLinear()`. This [github page](https://github.com/d3/d3-scale#linear-scales) offers a good introduction into what scale is and how to use them in D3.

Finally, the percentage of Christian population was referred from the dictionary that I created in the previous step. I set the style of `fill` as a function such that the percentage of Christian is gotten by setting the dictionary key as `properties.name_id` of each feature, which is then used to determine the color of each province accordingly. 

**b. Set interactive tooltip**

For each province feature, I also included an interacative tooltip that shows the name and the exact percentage of Christian population of each province. To do so, I added a tooltip `div` element to `<body>`, set the corresponding text up with `mouseover` activities and close it when mouse is out. The interactive tooltip was made possible thanks to the tutorial [Adding tooltips to a d3.js graph](http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html) and [Basic US State map](http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922) by Michelle Chandra.

Here is the corresponding Javascript code:

```
	// Append Div for tooltip to SVG
	// tooltip is possible thanks to: http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922 and http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html
        var div = d3.select("body")
		.append("div")   
    		.attr("class", "tooltip")               
    		.style("opacity", 0);
	
	// Define linear scale for output
        var color = d3.scaleLinear()
		.domain([0,1,2,3])
		.range(["rgb(255,225,225)","rgb(255,190,190)","rgb(255,150,150)","rgb(255,100,100)"]);
			
	Promise.all([indonesia]).then(function(values){  

		// draw map
		svg.selectAll("path")
			.data(values[0].features)
			.enter()
			.append("path")
			.attr("class","indonesia")
			.style("stroke", "white")
			.style("fill", function(d, i){
				//set the province path based on percentage of Christian population
				var name = d.properties.name_id;
				if (christian_dict[name] < 0.016655){
					return color(0)
				} else if (christian_dict[name] < 0.027265){
					return color(1)
				} else if (christian_dict[name] < 0.164778) {
					return color(2)
				} else{
					return color(3)
				};
			})
			.attr("d", path)
			.on("mouseover", function(d, i) {
				div.transition()        
					.duration(200)      
					.style("opacity", .9); 
						
				//set specific text to the tooltip
				div.text("Provinsi: " + d.properties.name_id + "\n" + "Persentase: " + Math.round(christian_dict[d.properties.name_id] * 10000) / 100 + "%")
					.style("left", (d3.event.pageX) + "px")     
					.style("top", (d3.event.pageY - 28) + "px"); 
				})
			.on("mouseout", function(d, i) {
				div.transition()        
					.duration(500)      
					.style("opacity", 0);
			})
```

Finally, I updated the `.css` file for the added .html elements. One specific step was that I lightened the province color on mouse hover. This feature is very important because Indonesian is an archipelago country and multiple provinces consist several islands that are quite hard to tell by simply looking at my map. With this feature, the user will know the specific size of each province more easily. I learned about this possibility thanks to [Basic US State map](http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922) by Michelle Chandra. 

```
/* Style for main map */
.indonesia {
    fill: #f0e4dd;
    stroke: #e0cabc;
    stroke-width: 0.5;
	fill-opacity = 0.5;
}

/* On mouse hover, lighten province color */
/* Reference: http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922 */
.indonesia:hover {
	fill-opacity: .7;
}


/* Style for Custom Tooltip */
div.tooltip {   
 	position: absolute;           
	text-align:center;           
	width: 250px;                  
	height: 28px;                 
	padding: 2px;             
	font: 12px sans-serif;        
	background: lightsteelblue;
	white-space: pre; 
	border: 0px;      
	border-radius: 8px;           
	pointer-events: none;         
}
```

#### 4. draw the labels 

After writing code that draws the map, I worked on the part of the code that appends the labels of each province in `Promise.all()` function. I appended the text features to `svg` and set the text as the Bahasa Indonesia name for each province feature. For two specific provinces, Daerah Khusus Ibukota Jakarta and Bangka Belitung, I have simplified their names to make my map more readable. I then based the `x` and `y` coordinates of each text on `properties.longitude` and `d.properties.latitude` values stored for each province feature and moved each province text around to better fit my map. I learned how to do this from this tutorial: [Making a Map in D3.js v.5](http://datawanderings.com/2018/10/28/making-a-map-in-d3-js-v-5/).

```
		// add labels
		svg.selectAll("text")
			.data(values[0].features)
			.enter()
			.append("text")
			.attr("class","labels")
			.text(function(d) {
				if (d.properties.name_id == "Daerah Khusus Ibukota Jakarta"){
					return "Jakarta";
				} else if (d.properties.name_id == "Kepulauan Bangka Belitung") {
					return "Bangka Belitung";
				}
				else{
					return d.properties.name_id;
				}
			})
			.attr("x", function(d) {
				//move each text feature around to better fit the map
				if (d.properties.name_id == "Daerah Khusus Ibukota Jakarta"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 15;
				} else if (d.properties.name_id == "Bali"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 5;
				} else if (d.properties.name_id == "Maluku" || d.properties.name_id == "Riau" || d.properties.name_id == "Aceh" || d.properties.name_id == "Nusa Tenggara Barat" || d.properties.name_id == "Nusa Tenggara Timur"){
					return projection([d.properties.longitude, d.properties.latitude])[0];
				} else if (d.properties.name_id == "Maluku Utara"){
					return projection([d.properties.longitude, d.properties.latitude])[0] + 30;
				} else if (d.properties.name_id == "Kepulauan Bangka Belitung"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 30;
				} else if (d.properties.name_id == "Sulawesi Tengah"){
					return projection([d.properties.longitude, d.properties.latitude])[0] + 5;
				} else if (d.properties.name_id == "Sumatera Barat"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 55;
				} else if (d.properties.name_id == "Gorontalo"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 25;
				} else if (d.properties.name_id == "Kalimantan Tengah" || d.properties.name_id == "Nusa Tenggara Barat"){
					return projection([d.properties.longitude, d.properties.latitude])[0] - 45;
				} else {
					return projection([d.properties.longitude, d.properties.latitude])[0] - 35;
				}
			})
			.attr("y", function(d) {
				//move each text feature around to better fit the map
				if (d.properties.name_id == "Daerah Khusus Ibukota Jakarta"){
					return projection([d.properties.longitude, d.properties.latitude])[1];
				} else if (d.properties.name_id == "Bali") {
					return projection([d.properties.longitude, d.properties.latitude])[1] + 5;
				} else if (d.properties.name_id == "Nusa Tenggara Timur" || d.properties.name_id == "Sulawesi Tenggara"){
					return projection([d.properties.longitude, d.properties.latitude])[1] + 25;
				} else if (d.properties.name_id == "Maluku"){
					return projection([d.properties.longitude, d.properties.latitude])[1] - 100;
				} else if (d.properties.name_id == "Maluku Utara"){
					return projection([d.properties.longitude, d.properties.latitude])[1] - 70;
				} else if (d.properties.name_id == "Kepulauan Bangka Belitung" || d.properties.name_id == "Kepulauan Riau"){
					return projection([d.properties.longitude, d.properties.latitude])[1] - 20;
				} else if (d.properties.name_id == "Sulawesi Barat"){
					return projection([d.properties.longitude, d.properties.latitude])[1] - 10;
				} else if (d.properties.name_id == "Gorontalo"){
					return projection([d.properties.longitude, d.properties.latitude])[1] + 5;
				} else {
					return projection([d.properties.longitude, d.properties.latitude])[1] + 10;
				}
			});
```

I also updated the `.css` file to show the change:

```
.labels {
	font-family: serif;
	font-size: 10px;
	font-weight: bold;
	fill: black;
	fill-opacity: 1;
}
```

#### 5.Create a legend and title
Finally, I appeneded a new svg each for my legend and title. The code for my legend is based on and modified from Basic US State map](http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922) by Michelle Chandra and [Donut Multiples](https://bl.ocks.org/mbostock/3888852) by Mike Bostock.

```
	//Create a Title for my map
	var title = d3.select("body").append("svg")
		.attr("class", "title")
		.attr("width", 1000)
		.attr("height", 100)
		.append("text")
		.attr("x", 0)
		.attr("y", 50)
		.style("font-size", "35px")
		.text("Peta persebaran Kristen di Indonesia berdasarkan sensus tahun 2010");
			
	// Modified Legend Code from Mike Bostock: http://bl.ocks.org/mbostock/3888852 and http://bl.ocks.org/michellechandra/0b2ce4923dc9b5809922
	var legend = d3.select("body").append("svg")
     	.attr("class", "legend")
   		.attr("width", 200)
   		.attr("height", 200)
		.selectAll("g")
		.data(color.domain().slice().reverse())
   		.enter()
   		.append("g")
		.style("background","yellow")
     		.attr("transform", function(d, i) { 
				return "translate(0," + i * 30 + ")" 
		});
			
	legend.append("rect")
		.attr("width", 28)
		.attr("height", 28)
		.style("fill", color);

	legend.append("text")
		.data(legendText)
		.attr("x", 34)
		.attr("y", 9)
		.attr("dy", ".55em")
		.text(function(d) { return d; });
```

Finally, I updated the corresponding `.css` file:
```
.title {
	position:absolute;
	left:700px;
	top:50px;
}

.legend {
	position:absolute;
	left:100px;
	top:850px;
}
```

## Result
[Here](Plots/test.html) is my result map and corresponding [css file](Plots/map.css). 
