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
require 'thread/pool'

config_file File.join("config","config.yml")

configure do
    REDIS = ConnectionPool.new(size: settings.redis_pool_size["search_app"]) do
        Redis.new(url: settings.redis_url)
    end
    LOGGER = Logger.new($stdout)
    THREADPOOL = Thread.pool(4)
end

enable :sessions

include Authentication
include UserService
include TestService
include TweetService
include RedisUtil

get '/api/search' do
    phrase = params[:phrase]
    paged = params[:paged]
    if !phrase
        return [400, "Invalid parameters!"]
    else
        THREADPOOL.process {
           result= doSearch(phrase, paged)
           LOGGER.info(result)
           puts result
           puts "??????"
           return result
        }
    end
end
