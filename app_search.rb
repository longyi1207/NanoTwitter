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
    @pusher = Pusher::Client.new(
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
    if !phrase
        return [400, "Invalid parameters!"]
    else
        THREADPOOL.process {
            if paged!=nil
                if session[:toId]!=nil && session[:toId]!=0
                    session[:toId] = session[:toId]+50
                else
                    session[:toId] = 100
                end
            else
                session[:toId] = 0
            end
            data = doSearch(phrase, paged, session[:toId])
            texts = data[0]
            likes = data[1]
            retweets = data[2]
            times = data[3]
            users = data[4]
            LOGGER.info "search texts #{texts}"
            LOGGER.info "search users #{users}"
            texts.each_with_index do |text, index|
                @pusher.trigger('my-channel', 'my-event', {
                    text: texts[index],
                    like: likes[index],
                    retweet: retweets[index],
                    time: times[index],
                    user: users[index]
                })
            end
        }
        
        return [200, "Success"]
    end

end