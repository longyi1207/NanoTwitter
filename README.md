# NanoTwitter Technical Report
By: Long Yi, Zhendan Xu, Lisandro Mayancela

Intro:
    For our group project, we were asked to demonstrate our understanding of scalability (specifically scaling out) by first implementing a basic version of Twitter (NanoTwitter/NT), using Sinatra and Postgresql, which contains some of the main features of Twitter proper (Tweets, Replies, Hashtags, Searching, etc.). Once completed, we deployed our NT to Heroku and began testing the performance of the app using Loader.io and test routes in order to identify which areas of our Twitter failed under increased load so that we could begin to implement various scaling practices discussed in class. This report will briefly outline our implementation of NanoTwitter before going in depth into defining the scalability techniques utilized, how they were implemented in our project, and what impact they had on our project’s performance. Finally, our group will reflect upon our project and offer key takeaways as well as a discussion of what we could’ve achieved given more time.

NanoTwitter Implementation & Architecture:
    When designing the initial schema for our NanoTwitter we wanted to support the following basic functionality and queries (This isn’t a comprehensive list but it contains the essential functionality):

*Users
Can post and reply to other tweets (“Return all of the tweets for a given user”/”Return all of this user’s replies”)
Can follow other users (“How many users are following a given user?”/”Who is this user following?”)
Can register/login/logout

*Tweets
Can contain a hashtag and a mention which can then be used for searching (“What are the tweets that contain a given hashtag/mention?”)
Can be replied to with another tweet (“What are the replies to this tweet?”/”Which tweet is this in response to?”)
Can be retweeted (“Which/How many users have retweeted this tweet?”)

*Searching
Can accept queries containing any number of keywords/hashtags/mentions and will return a “Timeline” of the most relevant tweets.

In order to achieve this, our group opted to have a schema consisting of 9 tables which can be observed below:

![alt text](https://i.gyazo.com/8eee96afa5ee44893c104e93479e19d5.png)

Once we had established the schema, our group split up the work of implementing the initial version as we created a UI, added model/integration tests, defined routes, included authentication using sessions, and finally deployed our first implementation of NanoTwitter to Heroku at the following link: https://cosi105nanotwitter.herokuapp.com (Below are screenshots of our UI). 

![alt text](https://github.com/longyi1207/NanoTwitter/blob/main/login.jpg?raw=true)
![alt text](https://github.com/longyi1207/NanoTwitter/blob/main/user.jpg?raw=true)

NanoTwitter Scaling:
Testing:
Prior to testing our application we first needed to establish a testing framework that would offer us a way to set up, execute, and then reset our tests. Moreover, we required the use of logging so that we could more precisely identify issues in our code and report the results of our tests. For our testing framework our group created routes such as those shown below (Not every test route is included):

/test/reset
/test/stress
/test/performance
/test/status

    Using the stress test as an example of how our testing framework was designed, these tests work by first defining the parameters for the test and then storing the current time as a variable (start_time/time_sum) which is then used to calculate the time it took for the operation that is being examined. In the case of the stress test, we were interested in the speed of following, tweeting, and fetching the user’s timeline. A code snippet of our stress test will be used to assist explanation:
    
get "/test/stress" do
    n = params[:n].to_i
    star = params[:star].to_i
    fan = params[:fan].to_i
 
// CODE SNIPPET. THIS ISN’T THE ENTIRE TEST \\
 
    text_list = []
    id_list = []
    time_sum = 0
    1.upto(n) do |i|
        text = Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity
        start_time = Time.now()
        tweet = doTweet(text, star)
        time_sum += Time.now()-start_time
        text_list.append(text)
        id_list.append(tweet.id)
    end
    LOGGER.info("TEST STRESS: userid=#{star} creates tweet AVERAGE TIME COST: #{time_sum/n} SECONDS")
 
    [200, "OK"]
end

    In order to test tweeting, we defined a variable time_sum which will store the total amount of time it took to perform n (parameter) tweets for user star (user_id passed as parameter). For each tweet, fake data using the Faker gem is created and then the time taken to create the tweet is calculated and added to time_sum. Once completed, the Logger gem is used to report the results of the test which we then reviewed via Papertrail.

Indexing:
    Indexing was the first avenue through which we tackled scaling our NanoTwitter as we had quickly realized that one of the most time consuming operations our app would need to perform was creating the timeline for a given user (list of tweets from users they are following and tweets that mention this user sorted by time). Without indexing, searches on a field such as the creation date would need to be linear, requiring the app to wait for the database to check, at worst, N records where N is the total number of records. For the tradeoff of requiring more disk space, we could instead index some of these fields so that their values can point to their corresponding entry, which is then sorted so that a faster search algorithm can be utilized. Thus, given how often we expect users to request their timeline (since it’s the first page the user sees after registering/logging-in), it was decided to add an index to the creation_date field of the Tweets table so that tweets can quickly be searched by that date. Furthermore, additional indices were added to the user_id foreign key of the Tweet table (tweet owner) as well as both foreign keys of the User_followers table. This was done in order to ensure that for any given user we would be able to not only quickly retrieve the user ids of their followers and followees, but also quickly retrieve the tweets which belong to any given user id. Finally, considering that users are searched via their usernames, we wanted to speed up the process in which a username can be used to retrieve its corresponding user_id. 
With all of this combined, our hope was that the use of these indices would provide a significant boost to how quickly timelines are created (For searches and home pages) and we made the following changes to our schema:

Tweets
Added Index to user_id foreign key and creation_date to speed up searching for tweets from a specific user and searching for tweets by when they were posted respectively

User_followers
Indexed both foreign keys in the table (follower_id, user_id)

Users
Indexed name to allow for faster searches on usernames 

Caching:
Services:
Queues:

Results of Scaling:
Conclusion:


How to Run and Other Notes:
# NanoTwitter 1.0
* Ruby version
"3.0.3"

* System dependencies
 "thin", "puma", "reel", "http", "webrick", "rake", "sinatra", "activerecord", "sinatra-activerecord", "pg", "rack-test", "faker", "bcrypt"

* Database creation
in postgres: create database nt_project_dev
in terminal: rake db:migrate

* How to run the app
in terminal: ruby app.rb

* generate random data
calling the route: localhost:5467/generateRandomData
generates 50 random users and 200 random tweets etc. for testing 

* How to run the test suite
in terminal: ruby test/test.rb

* Services (job queues, cache servers, search engines, etc.)
redis, snowflake?

* Deployment
https://cosi105nanotwitter.herokuapp.com/home

* Change History
NT-0.1 Feb14: create active record scheme, migration (Zhendan), and testing suite (Long)
NT-0.2 Mar2: create frontend UI (Long), deploy to heroku (Zhendan), create routes (Lisandro), authentication (Zhendan)
NT-1.0 Mar14: implement core function including user following (Zhendan), tweeting (Long), and timeline (Long)
NT-1.1 Mar16: add test interface (Zhendan, Long)
NT-1.2 Apr4: migrate follow related operations to redis (Zhendan)

  
