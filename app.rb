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
# These two will eventually become one once authentication is implemented.
get '/' do
    authenticate!
    redirect "/home"
end

get '/login' do
    erb :login
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

#### TWEETS ENDPOINTS
get '/tweets' do
	@tweet = Tweet.all
end

get '/tweets/count' do
    Tweet.all.count.to_s
end

post '/tweet/new' do
    @tweet= Tweet.create(text:Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity,
    user_id:rand(1..10), likes_counter:rand(0..100), retweets_counter:rand(1..100), 
    parent_tweet_id:rand(1..10), original_tweet_id:rand(1..10), create_time:Time.now())
end

delete '/tweets' do
    Tweet.delete_all
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
get '/testing' do
    for i in 1..10 do
         User.create(name:Faker::Name.name, password:Faker::Number.decimal_part, create_time:Time.now())
         
         Tweet.create(text:Faker::Name.name+" "+Faker::Verb.past+" "+Faker::Hobby.activity,
         user_id:rand(1..10), likes_counter:rand(0..100), retweets_counter:rand(1..100), 
         parent_tweet_id:rand(1..10), original_tweet_id:rand(1..10), create_time:Time.now())
         
         Tag.create(name:Faker::WorldCup.team)
         
         Retweet.create( user_id:rand(1..10), tweet_id:rand(1..10), tweet_user_id:rand(1..10), create_time:Time.now())
    
         UserFollower.create(user_id:rand(1..10),follower_id:(1..10))
         TagTweet.create(tag_id:rand(1..10), tweet_id:rand(1..10), create_time:Time.now)
         Like.create(user_id:rand(1..10), tweet_id:rand(1..10), tweet_user_id:rand(1..10), create_time:Time.now)
         Mention.create(user_id:rand(1..10), tweet_id:rand(1..10), tweet_user_id:rand(1..10), create_time:Time.now)
    end
end


delete '/testing' do
    User.delete_all
    Tweet.delete_all
    Tag.delete_all
    Retweet.delete_all
end