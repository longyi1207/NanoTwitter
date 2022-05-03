require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/config_file'
require 'active_record'
require 'connection_pool'
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
require_relative 'redisUtil.rb'
require 'faker'
require 'csv'
require 'json'
require "logger"
require "redis"

config_file File.join("config","config.yml")

configure do
    REDIS = ConnectionPool.new(size: settings.redis_pool_size) do
        Redis.new(url: settings.redis_url)
    end
    LOGGER = Logger.new($stdout)
end

enable :sessions

include Authentication
include UserService
include TestService
include TweetService
include RedisUtil

get '/' do
    "Hello world!"
end
