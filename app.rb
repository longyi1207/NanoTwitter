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
require 'faker'

get '/' do
    "hi"
    # erb :index
end

#### USER ENDPOINTS
get '/users' do
	@user = User.all
end

post '/newUser' do
    @user = User.create(name:Faker::Name.name,
        password:Faker::Number.decimal_part, 
        create_time:Time.now())
end

delete '/users' do
    User.delete_all
end

#### TWEETS ENDPOINTS
get '/tweets' do
	@tweet = Tweet.all
end

post '/newTweet' do
    @tweet= Tweet.create(text:"hi", user_id:1,
        likes:0, retweets:0, parent_tweet_id:1, 
        original_tweet_id:1, create_time:Time.now())
end

delete '/tweets' do
    Tweet.delete_all
end