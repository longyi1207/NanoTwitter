require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
require_relative 'models/tweet.rb'
require_relative 'models/user.rb'
require_relative 'models/tag.rb'
require_relative 'models/tagTweet.rb'
require_relative 'models/userFollower.rb'
require_relative 'models/mention.rb'
require_relative 'models/like.rb'
require_relative 'models/retweet.rb'
require_relative 'models/tweetReply.rb'
require_relative 'authentication.rb'
require_relative 'userService.rb'
require_relative 'testService.rb'
require_relative 'tweetService.rb'
require 'faker'
require 'csv'
require 'json'
require "logger"
require "remote_syslog_logger"

before do
    @logger = RemoteSyslogLogger.new('logs.papertrailapp.com','26749')
end

enable :sessions

include Authentication
include UserService
include TestService
include TweetService

get '/' do
    authenticate!
    redirect "/home"
end

get '/loaderio-7945fcb84861825ad8feaf1461ab7335/' do
    File.read(File.join('public', 'loaderio-7945fcb84861825ad8feaf1461ab7335.txt'))
end

get '/login' do
    erb :login
end

get '/logout' do
    session.clear
    @logger.info "Session data: #{session[:user]}"
    redirect '/login'
end

post '/login' do
    valid, data = authenticate(params)
    if valid 
        session[:user] = data
        @logger.info "Session data: #{session[:user]}"
        redirect_to_original_request
    else
        @error_message = data
        erb :login
    end
end

get '/home' do
    if params[:user_id]
        @user = User.find(params[:user_id].to_i)
    else
        authenticate!
        @user = session[:user]
    end
    @followingCount, @followerCount = getFollowerCount(@user["id"])

    @user_names, @tweet = fetchTimeline(@user["id"])

    @recommend_users = User.all
    if @recommend_users.length>10
        @recommend_users = @recommend_users[1..10]
    end
    @logger.info "user #{session[:user]["id"]} request timeline"
    erb :user
end


#### USER ENDPOINTS
###
get '/user/#id' do
    @user = User.find(id)
    @followingCount, @followerCount = getFollowerCount(@user["id"])
    followee = UserFollower.where("follower_id="+@user["id"].to_s).all
    followee_id = []
    followee.each do |f|
        followee_id.append(f["user_id"])
    end

    if followee_id.length==0
        @tweet = []
    else
        @tweet = Tweet.where("user_id=any(array"+ followee_id.to_s+")").order("create_time")
    end
    if @tweet.length>50
        @tweet = @tweet[1..50]
    end

    @user_names = []
    @tweet.each do |t|
        @user_names.append(User.find(t["user_id"]).name)
    end


    @recommend_users = User.all
    if @recommend_users.length>10
        @recommend_users = @recommend_users[1..10]
    end
    erb :user
end


get '/users' do
	@user = User.all
end

get '/users/count' do
    User.all.count.to_s
end

get '/users/new' do
    erb :signup
end

post '/users/new' do
    valid, data = createUser(params)
    if valid
        session[:user] = data
        redirect "/home"
    else
        @error_message = data
        erb :signup
    end
end

delete '/users/delete/:id' do
    User.delete_all
end

get '/users/follow/:flag' do
    #true: follower, flase: following
    authenticate!
    @flag = params['flag']
    @followersData = getFollowers(session[:user][:id], 0, 50)
    @followingData = getFollowing(session[:user][:id], 0, 50)
    @maxFollowersId = 0
    @maxFollowingId = 0
    if @followersData.ntuples > 0
        @maxFollowersId = @followersData[@followersData.ntuples-1]["fid"]
    end
    if @followingData.ntuples > 0
        @maxFollowingId = @followingData[@followingData.ntuples-1]["fid"]
    end
    erb :follower
end

post "/users/doFollow" do
    userid = params['userid']
    followUser(session[:user][:id], userid)
end

post "/users/doUnfollow" do
    userid = params['userid']
    unfollowUser(session[:user][:id], userid)
end

post "/users/getMoreFollowers" do
    offset = params['offset']
    getFollowers(session[:user][:id], offset, 10).to_json
end

post "/users/getMoreFollowing" do
    offset = params['offset']
    getFollowing(session[:user][:id], offset, 10).to_json
end


#### TEST ENDPOINTS

### I don't know how to parse local json file
get '/test/readCsv' do

    followData = File.open("./seeds/follows.csv").read
    userData = File.open("./seeds/users.csv").read
    tweetData = File.open("./seeds/tweets.csv").read

    userParse = CSV.parse(userData)
    followParse = CSV.parse(followData)
    tweetParse = CSV.parse(tweetData)

    userJson = userParse.map{ |e| {id: e[0], name: e[1]} }
    tweetJson = tweetParse.map{ |e| {user_id: e[0], text: e[1], create_time: e[2]} }
    followJson = followParse.map{ |e| {user_id: e[0], follower_id: e[1]} }
    File.open("user.json","w") do |f|
        f.write(userJson)
    end
    File.open("tweet.json","w") do |f|
        f.write(tweetJson)
    end
    File.open("follow.json","w") do |f|
        f.write(followJson)
    end

    # File.exist?("tweets.json")
end


get '/test/reset/standard' do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE users RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tweets RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tags RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE retweets RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_followers RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tag_tweets RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE likes RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE mentions RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tweet_replies RESTART IDENTITY")   

    followData = File.open("./seeds/follows.csv").read
    userData = File.open("./seeds/users.csv").read
    tweetData = File.open("./seeds/tweets.csv").read
    
    tweetN = params[:tweets]
    userN = params[:users]
    followN = params[:follows]

    userParse = CSV.parse(userData)[0..userN.to_i-1]
    followParse = CSV.parse(followData)[0..followN.to_i-1]
    tweetParse = CSV.parse(tweetData)[0..tweetN.to_i-1]

    userJson = userParse.map{ |e| {id: e[0], name: e[1]} }
    userJson.each_slice(1000).to_a.each do |data|
        User.insert_all(data)
    end

    tweetJson = tweetParse.map{ |e| {user_id: e[0], text: e[1], create_time: e[2]} }
    tweetJson.each_slice(1000).to_a.each do |data|
        Tweet.insert_all(data)
    end

    followJson = followParse.map{ |e| {user_id: e[0], follower_id: e[1]} }

    followJson.each_slice(1000).to_a.each do |data|
        UserFollower.insert_all(data)
    end

    status 200
end


get '/test/reset' do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE users RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE tweets RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_followers RESTART IDENTITY")

    followData = File.open("./seeds/follows.csv").read
    userData = File.open("./seeds/users.csv").read
    tweetData = File.open("./seeds/tweets.csv").read
    
    userN = params[:user_count]

    userParse = CSV.parse(userData)
    followParse = CSV.parse(followData)
    tweetParse = CSV.parse(tweetData)

    userIds = userParse[0..userN.to_i-1].map{ |e| e[0] }

    ## import followings of users
    relatedFollows = followParse.select{|e| (userIds.include?e[1]) || (userIds.include?e[0])} 
    followJson = relatedFollows.map{ |e| {user_id: e[0], follower_id: e[1]}}
    followJson.each_slice(1000).to_a.each do |data|
        UserFollower.insert_all(data)
    end

    ### import more users
    userIds = relatedFollows.flatten.uniq;
    userJson = userParse.select{|e| (userIds.include?e[0])}.map{ |e| {id: e[0], name: e[1]} }
    userJson.each_slice(1000).to_a.each do |data|
        User.insert_all(data)
    end
    
    ### import tweet by users
    tweetJson = tweetParse.select{|e| (userIds.include?e[0])}.map{ |e| {user_id: e[0], text: e[1], create_time: e[2]} }
    tweetJson.each_slice(1000).to_a.each do |data|
        Tweet.insert_all(data)
    end

    ### create test user
    ActiveRecord::Base.connection.reset_pk_sequence!('users')
    User.create(name:"testuser", password:"password")
    status 200
end

get "/test/tweet" do
    if params[:tweet_user].to_i <= 0 || params[:tweet_count].to_i <= 0
        return 400, "Params invalid!"
    end
    user = User.where(id: params[:tweet_user]).first
    if user == nil
        [400, "User does not exist!"]
    else
        1.upto(params[:tweet_count].to_i) do |i|
            Tweet.create(text:Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity,
                user_id:params[:tweet_user], likes_counter:0, retweets_counter:0, create_time:Time.now())
        end
        [200, "Success"]
    end
end

get "/test/status" do
    @users = User.all.count
    @follows = UserFollower.all.count
    @tweets = Tweet.all.count
    user = User.where(name: "testuser").first
    if user == nil
        @testUser = "Not exist"
    else
        @testUser = user.id
    end
    erb :status
end

get "/test/corrupted" do
    max = User.all.count
    1.upto(params[:user_count].to_i) do |i|
        userid = rand(1..max)
        if !userCorrupted?(userid)
            return [400, "Corrupted!"]
        end
        tweets = Tweet.where(user_id:userid)
        tweets.each do |t|
            if !tweetCorrupted?(tweet)
                return [400, "Corrupted!"]
            end
        end
    end
    [200, "OK"]
end

get "/test/stress" do
    n = params[:n].to_i
    star = params[:star].to_i
    fan = params[:fan].to_i
    check = UserFollower.where(user_id:star, follower_id:fan).first
    if check == nil
        UserFollower.create(user_id:star, follower_id:fan)
    end
    text_list = []
    id_list = []
    1.upto(n) do |i|
        text = Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity
        tweet = doTweet(text, star)
        text_list.append(text)
        id_list.append(tweet.id)
    end
    id_list.each do |i|
        getTweet(i)
    end
    user_names, tweet = fetchTimeline(fan)
    timeline = Set.new
    tweet.each do |t|
        timeline << t.id
    end
    id_list.each do |i|
        if !timeline.include?(i)
            return [400, "Timeline test failed!"]
        end
    end
    [200, "OK"]
end

#### TWEETS ENDPOINTS
get '/tweets' do
	@tweet = Tweet.all
end

get '/tweets/count' do
    Tweet.all.count.to_s
end

post '/tweet/randNew' do
    @tweet= Tweet.create(text:Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity,
    user_id:rand(1..10), likes_counter:rand(0..100), retweets_counter:rand(1..100), 
    parent_tweet_id:rand(1..10), original_tweet_id:rand(1..10), create_time:Time.now())
end

post '/tweet/new' do
    @tweet = parseTweet(params[:text], session[:user]["id"])
    @logger.info "user #{session[:user]["id"]} post tweet #{@tweet.id}"
    redirect "/home"
end

delete '/tweets' do
    Tweet.delete_all
end

post '/tweet/search' do
    if !params[:keyword].blank?
        @key = params[:keyword]
        @result = Tweet.where("text like '%"+@key+"%'")
        puts @result
        erb :searchResult
    end
end

#### TAG ENDPOINTS
get '/tags' do
	@tag = Tag.all
end

get '/tags/count' do
    Tag.all.count.to_s
end

post '/tags/new' do
    @tag= Tag.create(name:Faker::WorldCup.team)
end

delete '/tags/delete/:id' do
    Tag.delete_all
end


#### RETWEET ENDPOINTS
get '/retweets' do
	@retweet = Retweet.all
end

get '/retweets/count' do
    Retweet.all.count.to_s
end

post '/retweets/new' do
    @retweet=  Retweet.create( user_id:rand(1..10), tweet_id:rand(1..10), 
        tweet_user_id:rand(1..10), create_time:Time.now())
end

delete '/retweets/delete/:id' do
    Retweet.delete_all
end


#### tweetReply ENDPOINTS
#This may get deleted soon
get '/tweetReplies' do
	@tweetReplies = TweetReply.all
end

get '/tweetReplyCount' do
    TweetReply.all.count.to_s
end

post '/newTweetReply' do
    @tweetReplies=  TweetReply.create(text:Faker::Emotion.adjective, 
    tweet_id:rand(1..10), user_id:rand(1..10), reply_id:rand(1..10), reply_user_id:rand(1..10), create_time:Time.now())
end

delete '/tweetReplies' do
    TweetReply.delete_all
end


#### like ENDPOINTS
post '/like' do
    @like=  Like.create(user_id:rand(1..10), tweet_id:rand(1..10), tweet_user_id:rand(1..10), create_time:Time.now)
end


#### mention ENDPOINTS
post '/mention' do
    @mention=  Mention.create(user_id:rand(1..10), tweet_id:rand(1..10), tweet_user_id:rand(1..10), create_time:Time.now)
end


#### tagTweet ENDPOINTS
post '/tagTweet' do
    @tagTweet=  TagTweet.create(tag_id:rand(1..10), tweet_id:rand(1..10), create_time:Time.now)
end


#### userFollow ENDPOINTS
post '/userFollower' do
    @userFollower=  UserFollower.create(user_id:rand(1..10),follower_id:(1..10))
end


#### Generating ten rows for each table, for testing purpose
get '/generateRandomData' do
    User.delete_all
    Tweet.delete_all
    Tag.delete_all
    Retweet.delete_all
    UserFollower.delete_all
    TagTweet.delete_all
    Like.delete_all
    Mention.delete_all


    for i in 1..50 do
         User.create(name:Faker::Name.name, password:Faker::Number.decimal_part, create_time:Time.now())

         Tag.create(name:Faker::WorldCup.team)
         
         Retweet.create( user_id:rand(1..51), tweet_id:rand(1..200), tweet_user_id:rand(1..51), create_time:Time.now())
    
         UserFollower.create(user_id:rand(1..51),follower_id:rand(1..51))
         TagTweet.create(tag_id:rand(1..50), tweet_id:rand(1..200), create_time:Time.now)
         Like.create(user_id:rand(1..51), tweet_id:rand(1..200), tweet_user_id:rand(1..51), create_time:Time.now)
         Mention.create(user_id:rand(1..51), tweet_id:rand(1..200), tweet_user_id:rand(1..51), create_time:Time.now)
    end

    for i in 1..200 do
        Tweet.create(text:Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity,
            user_id:rand(1..51), likes_counter:rand(0..100), retweets_counter:rand(1..100), 
            parent_tweet_id:rand(1..200), original_tweet_id:rand(1..200), create_time:Time.now())
    end

    for i in 1..10 do
        UserFollower.create(user_id:rand(1..51),follower_id:51)
    end

    redirect "/home"
end

get "/generateFollowData" do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE users RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE user_followers RESTART IDENTITY")
    User.create(name:"test", password:"$2a$12$mr6D26FAAwzjQkB5jV2m0.13pp6CJnDh9xYUe4/.oOeryuXVHc8Vu", create_time:Time.now())
    for i in 1..100 do
        name = "name" + i.to_s
        user = User.create(name: name, password:Faker::Number.decimal_part, create_time:Time.now())
        UserFollower.create(user_id:1,follower_id:user.id)
        UserFollower.create(user_id:user.id,follower_id:1)
    end
end