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
require "pusher"
require 'thread/pool'

config_file File.join("config","config.yml")

configure do
    REDIS = ConnectionPool.new(size: settings.redis_pool_size["search_app"]) do
        Redis.new(url: settings.redis_url)
    end
    LOGGER = Logger.new($stdout)
    THREADPOOL = Thread.pool(4)
end

before do
    pusher = Pusher::Client.new(
        app_id: '1405458',
        key: 'f75186482c65c79ac41f',
        secret: '78c3e997b214b452f30c',
        cluster: 'us2',
        encrypted: true
    )
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
    pusher.trigger('my-channel', 'my-event', {
        message: 'hii'
    })
    if !phrase
        return [400, "Invalid parameters!"]
    else
        THREADPOOL.process {
            results = doSearch(phrase, paged)
            LOGGER.info "search results #{results[0]}"
            pusher.trigger('my-channel', 'my-event', {
                message: 'hello world',
                result: results[0],
                users: results[1],
                key: result[2]
            })
        }
        
        return [200, "Success"]
    end

end
