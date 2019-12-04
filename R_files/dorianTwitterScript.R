#search geographic twitter data for Hurricane Dorian, by Tiansheng Sun, modified based on Joseph Holler's original version, November 2019
#to search, you first need a twitter API token: https://rtweet.info/articles/auth.html 

#install package for twitter and initialize the library
install.packages(c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph"))
library(rtweet)
library(igraph)
library(dplyr)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)

############# SEARCH TWITTER API ############# 

#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "tianshengs",  					
  consumer_key = "wpiEdjQwWXNc3krsMxmbYlAOK",  		#replace yourkey with your consumer key
  consumer_secret = "CZ1NFPOdnxnNR7JTwjKdNmqKXZzhH8PH7fpJvutoJQ45yvy5Fz",  #replace yoursecret with your consumer secret
  access_token = NULL,
  access_secret = NULL
)

#get tweets for hurricane Dorian, searched on September 11, 2019
dorian1 <- search_tweets("dorian OR hurricane OR sharpiegate", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)

#get tweets without any text filter for the same geographic region in November, searched on November 19, 2019
#the query searches for all verified or unverified tweets, so essentially everything
november1 <- search_tweets("-filter:verified OR filter:verified", n=200000, include_rts=FALSE, token=twitter_token, geocode="32,-78,1000mi", retryonratelimit=TRUE)

############# FIND ONLY PRECISE GEOGRAPHIES ############# 

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

############# TEXT / CONTEXTUAL ANALYSIS ############# 

dorian$text <- plain_tweets(dorian$text)

dorianText <- select(dorian,text)
dorianWords <- unnest_tokens(dorianText, word, text)

# how many words do you have including the stop words?
count(dorianWords)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART")

dorianWords <- dorianWords %>%
  anti_join(stop_words) 

# how many words after removing the stop words?
count(dorianWords)

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

#"$" means a specific column
# mutate means to create a new variable

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


############### UPLOAD RESULTS TO POSTGIS DATABASE ###############

#Connectign to Postgres
#Create a con database connection with the dbConnect function.
#Change the database name, user, and password to your own!
con <- dbConnect(RPostgres::Postgres(), dbname='tiansheng', host='artemis', user='tiansheng', password='693834') 

#list the database tables, to check if the database is working
dbListTables(con) 

#create a simple table for uploading
dorian_sim <- select(dorian,c("user_id","status_id","text","lat","lng"),starts_with("place"))
november_sim <- select(november,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
#replace new_table_name with your new table name
#replace dhshh with the data frame you want to upload to the database 
dbWriteTable(con,'dorian',dorian_sim, overwrite=TRUE)
dbWriteTable(con,'november',november_sim, overwrite=TRUE)

#SQL to add geometry column of type point and crs NAD 1983: 
#INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');
#SELECT AddGeometryColumn ('public','dorian','geom',102004,'POINT',2, false);
#update dorian set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);
#SELECT AddGeometryColumn ('public','november','geom',102004,'POINT',2, false);
#update november set geom = st_transform(st_setsrid(st_makepoint(lng,lat),4326),102004);

#make all lower-case names for this table
counties <- lownames(Counties)
dbWriteTable(con,'counties',counties, overwrite=TRUE)
#UPDATE counties SET geometry = st_transform(geometry, 102004);
#SQL to update geometry column for the new table: select populate_geometry_columns('counties'::regclass);
#DELETE FROM counties
#WHERE statefp NOT IN ('54', '51', '50', '47', '45' ,'44', '42', '39', '37', '36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17', '13', '12', '11', '10', '09', '05', '01');

#disconnect from the database
dbDisconnect(con)



