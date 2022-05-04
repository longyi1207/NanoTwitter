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

config_file File.join("config","lb_config.yml")

enable :sessions

include Authentication
include UserService
include TestService
include TweetService
include RedisUtil

configure do
    URLS = settings.web_urls
    MAX = URLS.length()-1
    set :counter, 0
end

get '*' do
    if settings.counter >= MAX
        settings.counter = 0
    else
        settings.counter = settings.counter + 1
    end
    puts settings.counter
    redirect URLS[settings.counter]+request.fullpath, 307
end
