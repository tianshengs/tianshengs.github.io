# Sharpie versus Storm Surge in the Twittersphere of Hurricane Dorian

### Introduction
Social Media data, for example, Twitter data, has increasingly become more important in helping us understand our world. Specifically, in the discipline of geography, Twitter data can be used to understand real time geographic phenomenon and distribution across space. Although unfortunately only 1% of all Tweets on Twitter have geo-coordinates, we may extract these tweets with geo-coordinates and use it for our research. In the era of big data, these tweets can be extremely powerful and can provide us with very important insights and findings that other sources of data cannot provide.

One specific use of Twitter data in the discipline of geography is to understand the geographic and spatial clustering of tweet activities over a specific event. When something happens, people from different locations may react to the event differently. A look into potential geographic clustering of tweet activities over this specific event can therefore tell us a lot about this event and help us think about the potential factors that affect people's reactions over the event by looking at the most common words, word association or geographic clustering patterns of all tweets of interest.

### Study case: Dorian hurricane

Hurrican Dorian was a powerful hurricane that was first formed in August 24th over the central Atlantic. As the hurricane became extremely strong, the hurricane stroke through the Bahamas, causing a lot of damages to the country. Then, on Semptember 3rd, the hurricane entered the United States from Florida all the way to the Northeastern coast of the United States and Nova Scotia in Canada, and was finally dissapated in New Foundland in September 10th.

This graph shows the actual Dorian Hurricane's path in the United States:
![Screenshot-2019-12-4 Live Maps Tracking Hurricane Dorian’s Path](https://user-images.githubusercontent.com/25497706/70168429-d99be700-1696-11ea-9106-61c3765f5a20.png)
[Map Source](https://www.nytimes.com/interactive/2019/09/06/us/hurricane-dorian-path-map-track.html): Matthew Bloch and Denise Lu (2019). Live Maps: Tracking Hurricane Dorian’s Path. *New York Times.*

On September 4th, however, President of the United States Donald Trump presented a sharpied map of Hurrican Dorian, which shows that Alabama was one of the state that will be hit hard by Hurrican Dorian. However, as we see from the actual path of Dorian Hurricane, Alabama was not influenced by Dorian Hurricane. 

Here is a photo of the map that President Donald Trump presented:
![1172289651 jpg 0](https://user-images.githubusercontent.com/25497706/70169179-4d8abf00-1698-11ea-8464-d750c3133a49.jpg)
[Image Source](https://www.vox.com/policy-and-politics/2019/9/6/20851971/trump-hurricane-dorian-alabama-sharpie-cnn-media): Stewart, E. (2019). The incredibly absurd Trump/CNN SharpieGate feud, explained. *VOX.*

Apprently, Donald Trump's map, with this laughable mistake, has received wide notice on social media. However, it would be interesting to use Twitter Data to understand whether the actual storm path or President Trump's sharpie maps had more influence on driving Twitter activity in Eastern United States. 

For this project, I looked at the Twitter data about Dorian Hurricane starting from September 11, 2019 and conducted textual analysis in RStudio and spatial analysis in QGIS to understand this case. Textually, I looked at the most popular keywords and associations of common words to see if any specific words such as "Alabama" or "Trump" stand out. Spatially, I plan to see if there is a spatial clustering in the number of tweets related to Dorian Hurricanes. Is Alabama part of the spatial cluster and what about the counties along the coast that were actually hitted by Hurrican Dorian? This look into the spatial clustering of Twitter data can also help us understand the impact of Trump's Sharpied map and the actual path of Dorian hurricane.

### Data
For this activity, I used two data frames:

a. **dorian**: 200,000 tweets from September 11, 2019 that contained keywords “dorian,” “hurricane” or “sharpiegate”.

b. **november**: 200,000 tweets from November 19, 2019 that reflects the baseline Twitter activity across space.

Professor Joseph Holler helped provide the sample Twitter data used for this activity and the R code used to generate the data.
`search_tweets` query was first used to get specific data from Twitter, and GPS coordinates was then converted into lat and lng columns with the `lat_lng` query. Then, `subset` query was used to select any tweets with lat and lng columns (from GPS) or designated place types of 'city', 'neighborhood' and 'poi'. This step is important because not all tweets have geographic coordinates. The final step is to convert bounding boxes of each place into centroids for lat and lng columns. Now the two data frames are now ready for use.
```
#get tweets for hurricane Dorian, searched on September 11, 2019
dorian1 <- search_tweets("dorian OR hurricane OR sharpiegate", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)

#get tweets without any text filter for the same geographic region in November, searched on November 19, 2019
#the query searches for all verified or unverified tweets, so essentially everything
november1 <- search_tweets("-filter:verified OR filter:verified", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)

#reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
#adds a lat and long field to the data frame, picked out of the fields you indicate in the c() list
#sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

#convert GPS coordinates into lat and lng columns
dorian <- lat_lng(dorian,coords=c("coords_coords"))
november <- lat_lng(november,coords=c("coords_coords"))

#select any tweets with lat and lng columns (from GPS) or designated place types of your choosing
dorian <- subset(dorian, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))
november <- subset(november, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))

#convert bounding boxes into centroids for lat and lng columns
dorian <- lat_lng(dorian,coords=c("bbox_coords"))
november <- lat_lng(november,coords=c("bbox_coords"))
```

### Method
This activity is split into three sections: Textual analysis in RStudio, SQL spatial analysis in QGIS, and clustering visualization in GeoDa.

#### (1). Textual analysis
I modified the R file to do the following text/contextual analysis: 

**a. most popular words**

To get the most popular words, I first have to get the plain tweet texts of all dorian tweets of interest. I used the function `plain_tweets` to get a reformatted data without URL links, line breaks, fancy spaces/tabs, fancy apostrophes etc. in the text column of the database. Then, I used the function `select` to select only the text column of the data base and use the function `unnest_tokens` to split a column into word tokens.

After that, I created a list of stop words (useless words) and added "t.co" twitter links to the list. This step is important because common stop words such as *"and"* and *"or"* are useless and cannot provide any contextual information for my analysis purpose. "t.co" links are also deleted because we do not want to include these links in our most common words list. I used the function `anti_join` to find all word tokens from dorian words that are not stop words. Once the stop words have been deleted, I created a graph of the most popular 20 words found in tweet using `ggplot`.

Here is the specific R code that I ran to get my graph.
```
#get the plain tweet texts of all dorian tweets
dorian$text <- plain_tweets(dorian$text)

dorianText <- select(dorian,text)
dorianWords <- unnest_tokens(dorianText, word, text)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART")

dorianWords <- dorianWords %>%
  anti_join(stop_words) 

#create a graph of the most popular 20 words found in tweets
dorianWords %>%
  count(word, sort = TRUE) %>%
  top_n(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in Dorian tweets")
```

**b. association of common keywords**
To get the association of coomon keywords, I first used the function `unnest_tokens` to get word pairs from all tweets of interest and used the function `seperate` to split the column into two. Then, I used the `count` function to count the number of associations for each word and sorted the data frame based on the number of associations. Finally, I created the graph of a word cloud with space indicating association for all words with more than 30 instances using `ggraph`.

Here is the specific R code that I ran to get my graph.
```
#find all the word pairs
dorianWordPairs <- dorian %>% select(text) %>%
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)

#finding the count of the dorian word pairs that exist 
dorianWordPairs <- separate(dorianWordPairs, paired_words, c("word1", "word2"),sep=" ")
dorianWordPairs <- dorianWordPairs %>% count(word1, word2, sort=TRUE)

#graph a word cloud with space indicating association for words with more than 30 instances. 
dorianWordPairs %>%
  filter(n >= 30) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  # geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: Tweets of Dorian Hurricane",
       subtitle = "November 2019 - Text mining twitter data ",
       x = "", y = "") +
  theme_void()
```

**c. uploade to PostSQL database**

As the final step, I uploaded the twitter data frames into my PostSQL database so that I could use them in QGIS for SQL spatial analysis. I also downloaded county-level geographic and population data from the U.S. Census and uploaded all the counties into my PostGIS database.

Here is how I uploaded the two data frams into my PostGRESQL dadtabase after connecting to my database:
```
#get a Census API here: https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
Counties <- get_estimates("county",product="population",output="wide",geometry=TRUE,keep_geo_vars=TRUE, key="yourkey")

#create a simple table for uploading
dorian_sim <- select(dorian,c("user_id","status_id","text","lat","lng"),starts_with("place"))
november_sim <- select(november,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
dbWriteTable(con,'dorian',dorian_sim, overwrite=TRUE)
dbWriteTable(con,'november',november_sim, overwrite=TRUE)

#make all lower-case names for this table
counties <- lownames(Counties)
dbWriteTable(con,'counties',counties, overwrite=TRUE)
```

#### (2). SQL spatial analysis

Once I have uploaded all data tables into my PostGIS database, I conducted spatial analysis in QGIS with SQL queries. First of all, I added geometry to my three data frames and transformed them to USA Contiguous Lambert Conformal Conic projection. Then, since I wanted to look at only counties in Eastern United States, I deleted the Western states from the census data layer. After that, I counted the number of each type of tweet (dorian and november) by county and normalized the data using the following two methods:

**a. the number of tweets per 10,000 people**

**b. a normalized tweet difference index: (tweets about storm – baseline twitter activity)/(tweets about storm + baseline twitter activity)**

[Here](queries/twitter.sql) are the specific SQL queries that I ran:

```
/*Tiansheng Sun Twitter Analysis*/

/*insert the spatial reference system needed for this analysis*/
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');

/*Create a point geometry for dorian twitter data*/
SELECT AddGeometryColumn ('public','dorian','geom',102004,'POINT',2, false);
update dorian set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);

/*Create a point geometry for all november twitter  data*/
SELECT AddGeometryColumn ('public','november','geom',102004,'POINT',2, false);
update november set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);

/*select only the counties that we are interested in looking*/
UPDATE counties SET geometry = st_transform(geometry, 102004);
select populate_geometry_columns('counties'::regclass);
DELETE FROM counties
WHERE statefp NOT IN ('54', '51', '50', '47', '45' ,'44', '42', '39', '37', '36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17', '13', '12', '11', '10', '09', '05', '01');

/*add which county each november post is located in*/
ALTER TABLE november ADD COLUMN geoid varchar(5);
UPDATE november SET geoid = a.geoid
FROM counties as a
WHERE st_intersects(geom, a.geometry);

/*get the total number of november post in each state*/
SELECT geoid, COUNT(geoid) FROM november GROUP BY geoid;

/*add which county each dorian post is located in*/
ALTER TABLE dorian ADD COLUMN geoid varchar(5);
UPDATE dorian SET geoid = a.geoid
FROM counties as a
WHERE st_intersects(geom, a.geometry);

/*get the total number of dorian post in each state*/
SELECT geoid, COUNT(geoid) FROM dorian GROUP BY geoid;

/*add the number of total number of november posts to each county*/
ALTER TABLE counties ADD COLUMN count int;
UPDATE counties SET count = 0;
UPDATE counties SET count = a.count
FROM (SELECT geoid, COUNT(geoid) as count FROM november GROUP BY geoid) AS a
where counties.geoid = a.geoid

/*add the number of total number of dorian posts to each county*/
ALTER TABLE counties ADD COLUMN count_dorian int;
UPDATE counties SET count_dorian = 0;
UPDATE counties SET count_dorian = a.count
FROM (SELECT geoid, COUNT(geoid) as count FROM dorian GROUP BY geoid) AS a
where counties.geoid = a.geoid

/*calculate the number of Dorian tweets per 10000 people*/
ALTER TABLE counties ADD COLUMN tweet_rate real;
UPDATE counties SET tweet_rate = count_dorian / pop * 10000.0

/*calculate the ndti (tweets about dorian - baselind november twitter activity)/(tweet about storm + baseline november twitter activity)*/
ALTER TABLE counties ADD COLUMN ndti real;
UPDATE counties SET ndti = 0.0;
UPDATE counties SET ndti = 1.0 * (count_dorian-count)/(count_dorian + count)
WHERE count_dorian > 0 or count > 0
```

Finally, I converted counties shapefile into centroid points and create a heatmap (Kernel Density) of tweets using the Heatmap algorithm in QGIS with a radius of 100 kilometers, the weight from field to the tweeet rate column, and the pixel sizes to 500. Note that these numbers are arbitrary selections with the purpose to get continuity between data points and a smooth visualization without running too long.

#### (3). Clustering visualization

G*, or so-called Getis-Ord Statistic, is a useful tool for hot spot analysis. 
Below is how the G* score is calculated:

![GUID-AEFD71B5-BE33-42AB-84FB-AEE3FD5E2114-web](https://user-images.githubusercontent.com/25497706/70180707-8cc40a80-16ae-11ea-93f7-35866850b831.png)

Image from ArcMap's [documentation on Hot Spot Analysis (Getis-Ord Gi*)](https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-hot-spot-analysis-getis-ord-gi-spatial-stati.htm) 

In GeoDa, I created spatial cluster map of tweets related to Dorian hurricane using the G* cluster algorithm. First of all, I create a spatial weights matrix using **Tools->Weights Manager** in GeoDa. Then, I created the local G* cluster statistic map of tweets per 10,000 people using the **Space->local G* cluster map** menu and setted the variable to the `tweet rate` column. I did not make the local G* cluster statistic map of the normalized tweet difference index that I used, because the negative input values of the analysis will produce unpredictable and possibly inaccurate result. However, the normalized tweet difference index is good for showing the result in a choropleth map. Areas with a possible value correspond to areas with above average tweet activity, and areas with a negative value are the regions with below average tweet activity.

### Results

#### Textual Analysis Graphs

**1. A graph of most common 20 keywords in tweet content**

![count](https://user-images.githubusercontent.com/25497706/70108730-f80ecd80-1617-11ea-9ee3-36946303a0e9.png)

From the graph, it is interesting to see that "alabama", "sharpiegate", "trump", "donaldtrump" as the 3rd, 4th, 6th and 7th most common words of all Tweets of interest, and only "hurricane" and "dorian" have significantly more appearence in all tweets. Although "carolina", "north" and "florida" are also among the top 20 words that appeared, they only ranked 13th, 19th and 14th.

#### 2. A graph of association of common keywords in tweet content during Dorian storm with more than 30 instances

![word_association](https://user-images.githubusercontent.com/25497706/70109428-dca4c200-1619-11ea-94e0-3b2f1bfc0dc1.png)

From the graph, we can see that "alabama" is extremely close to the word "dorian". Indeed, "alabama" is the closest word to "dorian" of all common words showed in the word cloud. This association is even stronger than between "dorian" and "bahamas", where the hurricane costed the most damage. On the other hand, "carolina", "georgia" and "florida" are quite far from the word "dorian".

#### Spatial Analysis Graphs

#### 3. Heatmap (Kernel Density) of tweet activities on Durian Hurricane

![heatmap](https://user-images.githubusercontent.com/25497706/70110865-65256180-161e-11ea-866f-933db7927711.png)

The heat map shows the kernel density of tweet activities on Durian Hurricane. Areas with higher values, meaning a higher proportion of twitter activity, are shown in darker red and areas with lower values, meaning a lower proportion of twitter activity, are shown in white color. We can see that there was a specifically high amount of twitter activity in the District of Columbia and coastal counties of North and South Carolina, Virgnia and Massachusetts, regions that were struck by Hurricane Dorian. The Midwest and the Deep South, including Alabama, had a relatively low amount of twitter activity.

#### 4. Spatial hotspot maps (G*) of tweets per 10,000 people during the storm by county

The first map shows the area with significant high and low twitter activity with p = 0.05.
![G_map](https://user-images.githubusercontent.com/25497706/70108331-11634a00-1617-11ea-8087-f1db5e6e7dea.png)

The second map shows the changing significance with changing p value.
![G_map2](https://user-images.githubusercontent.com/25497706/70108661-d57cb480-1617-11ea-8463-cefbb3c389d2.png)

The spatial hotspot map (G*) with p=0.05 significane shows a similar pattern that Coastal Virginia, North and South Carolina and Florida and the Cape Code region of Massachussets have significantly higher twitter activities about Dorian Hurricane and counties further to the West in Northern Louisiana, Eastern and Southern Arkansas, Mississippi, Kentucky, Southern Illionis, Southeastern Missouri and Southern Indiana have significantly lower twitter activity. If we lower the p value to 0.001 level, then we see that counties in Coastal North Carolina and Southern Virginia (around Norfolk and Virginia Beach) and Cape Cod region remain significant, as well as a large region around Kentucky, Southern Illinois and Idiana and pockies of counties in Arkansas and Mississippi.

### Analysis

#### a. Trump's Sharpie Map or actual storm path?

From the result maps, we can see the effects of both Trump's Sharpie Map and the actual storm path. However, the actual storm path seemed to influence where the tweets came from and the Trump's Sharpie Map seemed to influence the contents of the tweets. Because of the actual storm path in coastal North Carolina and Virgnia affected the people living in the region, people from these regions are more likely to tweet tweets related to Dorian Hurricane. However, because of the mistake of Trump's Sharpie map, the topic seemed to be the main topic many tweets were about from people who lived in regions influenced by Dorian.

#### b. Critical thinking of Twitter Data Analytics

Using social media data, such as Twitter Data, has becoming more popular and this bottom-up method of data collection and research provides a somewhat open-source and well-distributed data from across a lot of groups of people. However, I have to debate the "a lot of groups of people" point that I made in my previous sentence. One disadvantage of using Twitter Data is that places with more people and higher population density will in nature have more tweets. Therefore, we hae to normalize the data in order for it to be valuable; otherwise, the data analysis, for many cases, will be quite similar to a population density map. In my approach, I normalized the tweets by total population to get rid of the effect of population density. However, one should still be aware that the demographics of Twitter data will play an important role and can challenge the accuracy of analysis. Like what Florea, A. and Roman, M. (2018) suggested, many twitter users are indeed young people, compared to elderly people. This suggests that larger cities, such as Chicago, New Orleans, Norfolk and Virgnia Beach, with more young adults, may have a dispropotionately higher number of twitter users than the surrounding rural areas. However, given that demographic information are confidential, it is very hard for us to analyze the effect that demographics may play a role in our dataset.

Moreover, we have to realize that only approximately 1-2% of all tweets include geographic information. Although we can get a large enough data set for analysis, like what I did for this project, we surely ignored a lot of other tweets for spatial analysis. For example, we do not know if people who live in counties affected by Dorian Hurricanes are more likely to tag themselves compared to a random people in the Midwest. The geographic information used in Twitter is also not very precise. The geospatial information of tweets are defined by a bounding box, using a group of four coordinates to define each specific geographic location. The bounding box may be highly imprecise when we, for example, analyze a place that involves borders. Therefore, we have to be well aware of the limitation of geogrpahic information of Twitter data before we conduct any geography-related projects using Twitter data.

Finally, Twitter analysis using Twitter data may not be the most reproducible because of the confidentiality of Twitter data. Since twitter data usually includes a lot of personal information, these data are highly confidential and cannot be widely shared to other people. For research purpose, we also cannot include any part of our data in our final result, neither can we use demographic information for research purposes. To maximize reproducibility, it is OK for researches to include twitter status ID's in their researches, but researches should be careful and be aware of the possible lack of reproducibility of their projects.

**Reference**: 

Florea, A. and Roman, M. (2018). Using Face Recognition with Twitter Data for the Study of International Migration. Informatica Economică, 22, 4

#### [Back to Main Page](index.md)
