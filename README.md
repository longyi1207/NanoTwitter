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
NT-0.2 Mar2: create frontend UI (Long), deploy to heroku (Zhendan), create routes (Lisandro)
NT-1.0 Mar14: implement core function including user following (Zhendan), tweeting (Long), and timeline (Long)


SCREENSHOT:
![alt text](https://github.com/longyi1207/NanoTwitter/blob/main/login.jpg?raw=true)
![alt text](https://github.com/longyi1207/NanoTwitter/blob/main/user.jpg?raw=true)

  
