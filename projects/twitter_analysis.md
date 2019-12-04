# Sharpie versus Storm Surge in the Twittersphere of Hurricane Dorian

### Method
This activity is split into three sections: Twitter data preparation and textual analysis in RStudio, SQL spatial analysis in QGIS, and clustering visualization in GeoDa.

#### (1). Twitter data preparation and analysis
For this activity, I used two data frames:

a. **dorian**: 200,000 tweets from September 11, 2019 that contained keywords “dorian,” “hurricane” or “sharpiegate”.

b. **november**: 200,000 tweets from November 19, 2019 that reflects the baseline Twitter activity across space.

Professor Joseph Holler helped provide the sample Twitter data used for this activity and the R code used to generate the data.
"search_tweets" query was first used to get specific data from Twitter, and GPS coordinates was then converted into lat and lng columns with the "lat_lng" query. Then, "subset" query was used to select any tweets with lat and lng columns (from GPS) or designated place types of 'city', 'neighborhood' and 'poi'. This step is important because not all tweets have geographic coordinates. The final step is to convert bounding boxes of each place into centroids for lat and lng columns. Now the two data frames are now ready for use.
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

I then modified the R file to do the following text/contextual analysis: 

**a. most popular words**

The following R code was run to get the most popular 20 words used in all tweets of interest.

```
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

The following R code was run to get a word cloud of association of common keywords in tweet content during Dorian storm with more than 30 instances

```
#find all the word pairs
dorianWordPairs <- dorian %>% select(text) %>%
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)

#finding the count of the dorian word pairs that exist 
dorianWordPairs <- separate(dorianWordPairs, paired_words, c("word1", "word2"),sep=" ")
dorianWordPairs <- dorianWordPairs %>% count(word1, word2, sort=TRUE)

#graph a word cloud with space indicating association with 30 instances. 
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

Finally, I uploaded the twitter data frames into my PostGRESQL database so that I can use them in QGIS for SQL spatial analysis.I also downloaded county-level geographic and population data from the U.S. Census and upload all the counties into my PostGIS database.

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
Once I have uploaded all data tables into my PostGIS database, I conducted spatial analysis in QGIS with SQL queries. First of all, I added geometry to my three data frames and transformed them to USA Contiguous Lambert Conformal Conic projection. Then, since I want to look at only county in Eastern United States, I deleted the states that I am not interested in from the census data layer.After that, I counted the number of each type of tweet (dorian and november) by county and normalize the datausing the following two methods:

**a. the number of tweets per 10,000 people**

**b. a normalized tweet difference index: (tweets about storm – baseline twitter activity)/(tweets about storm + baseline twitter activity)**

[Here](../queries/twitter.sql) are the specific SQL queries that I ran:

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

Finally, I visulized clustering in GeoDa. First of all, I create a spatial weights matrix using **Tools->Weights Manager**. Then, I created the local G* cluster statistic map of tweets per 10,000 people and the normalized tweet difference index that I used using **Space->local G* cluster map** and setted the variable to the specific column.

### Results
#### 1. A graph of most common 15 keywords in tweet content
![count](https://user-images.githubusercontent.com/25497706/70108730-f80ecd80-1617-11ea-9ee3-36946303a0e9.png)

#### 2. A graph of association of common keywords in tweet content during Dorian storm with more than 30 instances
![word_association](https://user-images.githubusercontent.com/25497706/70109428-dca4c200-1619-11ea-94e0-3b2f1bfc0dc1.png)

#### 3. Spatial hotspot maps(G*) of tweets per 10,000 people during the storm by county
The first map shows the area with significant high and low twitter activity with p = 0.05.
![G_map](https://user-images.githubusercontent.com/25497706/70108331-11634a00-1617-11ea-8087-f1db5e6e7dea.png)

The second map shows the changing significance with changing p value.
![G_map2](https://user-images.githubusercontent.com/25497706/70108661-d57cb480-1617-11ea-8463-cefbb3c389d2.png)

#### 4. Spatial hotspot maps(G*) of a normalized tweet difference index (tweets about storm – baseline twitter activity)/(tweets about storm + baseline twitter activity)
The first map shows the area with significant high and low twitter activity with an alpha level of 0.05.
![G_map4](https://user-images.githubusercontent.com/25497706/70108682-df9eb300-1617-11ea-88dc-53e0c1eaba89.png)

The second map shows the changing significance with changing p value.
![G_map3](https://user-images.githubusercontent.com/25497706/70108703-eaf1de80-1617-11ea-96ea-06c47b706d12.png)

#### 5. Heatmap (Kernel Density) of tweet activity on Durian Hurrican
![heatmap](https://user-images.githubusercontent.com/25497706/70110865-65256180-161e-11ea-866f-933db7927711.png)

