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
require 'faker'

enable :sessions

include Authentication
include UserService

get '/' do
    authenticate!
    redirect "/home"
end

get '/login' do
    erb :login
end

get '/logout' do
    session.clear
    redirect '/login'
end

post '/login' do
    valid, data = authenticate(params)
    if valid 
        session[:user] = data
        redirect_to_original_request
    else
        @error_message = data
        erb :login
    end
end

get '/home' do
    authenticate!
    @user = session[:user]
    @followingCount, @followerCount = getFollowerCount(@user)
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

#### USER ENDPOINTS
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
    authenticate!
    @flag = params['flag']
    erb :follower
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
    @tweet= Tweet.create(text:params[:text], user_id:session[:user]["id"], likes_counter:0, retweets_counter:0, parent_tweet_id:0, original_tweet_id:0, create_time:Time.now())
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