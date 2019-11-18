## Using Face Recognition with Twitter Data for the Study of International Migration

#### Article: [Florea, A. and Roman, M. (2018). Using Face Recognition with Twitter Data for the Study of International Migration. *Informatica Economică, 22, 4*](http://revistaie.ase.ro/content/88/03%20-%20florea,%20roman.pdf)

### Overview
The article presented a technique that collect and analyze Twitter data and use face recogination technology to predict active
Twitter users' demographics such as age, gender and race. Further more, twitter data can be used to understand the mobility of Twitter users' potential
mobility by examining the change of permenant address, which provides insight into global migration.

The approach of the paper is deductive. The authors first talk about the migration patterns of Romania as an introductsion to the topic, and then
provides literary rreviews of how Twitter data has been used to understand international migration. Then, the authors talk about the new technologies
for migration research, specifically R, Social Media data and face recognition, and finally use the Twitter data of Romanian users as an example of how 
these technologies can be useful in final research of global migration. In the end, the author shares how the topic can be further explored in the future.

### Method
The authors conducted their research in RStudio. For face recognition, they used the algorithm provided by Kairos, which handles the complexity of image 
processing by using neural network. In the paper, the authors built an innovative algorithm with eleven steps to combine the power of face recognition
with that of social media to identify demographic characteristics of the profthe individuals using Twitter:

The first step involves gaining social network platform agreement and the installation of needed R libraries. The next two steps prepares the settings for 
the analysis, as we call libraries (Step 2) and connect to twitter API (step 3). Steps 4 and 5 represent the raw collection of information,
as the author collected RO_located users (Step 4) and RO_speaker users (Step 5). After that, we merge data sets (Step 6), check current database (Step 7), add last status (Step 8) and add geo-located tweets (Step 9), all of which facilitate the increase of usage effectiveness. In the 10th step, the authors leveraged the 
face-recognition algorithm to estimate demographic details of the Twitter users. Once we get the result, we finally update the information into the existing
database.

### Data Analysis
The authors provides detailed information and code of some steps of data analysis. First of all, as the first step, the authors loaded three libraries:
```
# twitterR facilitates the communication with Twitter
library(twitteR)
# facerec facilitates the communication with Kairo face recognition sources
library(facerec)
# provide predefined variables
library(data.table)
```
After setting up RO script, the authors collected the coordinates of the biggest 150 cities of Romania. With the coordinates, the authors searched for the top 100,000 tweets in Romania since 2018/01/01, with a 20km buffer from the city
center of each city which covers the whole of Romania. 

After the process of data cleaning, the authors ran the code that calls facerec to analyze profile images of Twitter users. However, if the user does not include a profile picture, then the algorithm will generate and take the value "not face detected”.

Finally, the authors briefly talked about how exmaning the change of permenant address can provide insight into global migration. Specifically, the author reported
the percentage change of permenant location in Romania that has changed the country location.

### Result
Of the 100,000 tweets, the authors obtained infrmation of around 60,000 Twitter users from Romania. However, only 59% of them have a profile picture which can be used for demographic analysis.
Using the face recognition technology, the authors showed that 73% of selected users are "White", 55% are men and 45% are women, yet in the age group,
the percentage of men increases in the older groups and the number of women is bigger in the "under 25-year-old category".

Of all the users, 20%(12,000 users) declared they have a permenant residence in Romania. Of these users, 0.2% has changed their their permenant location
to a foreign country within in one month. Looking at the migration of these Twitter users, the author argued that the proxies of the very recent
migration can be developed and mobility trends can be identified long before any official documents.

### Replicability and reproducability
Although the authors provided a very detailed information about how they selected data, I think it may be hard to completely reproduce their result given that the face recognition technology may prouce slightly different 
results each time.Yet, I think that the research is highly replicable. We can easily use the same method to do some research of, for example, Chinese or Tanzanian twitter users, and  
