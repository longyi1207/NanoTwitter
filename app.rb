require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
require_relative 'models/tweet.rb'
require_relative 'models/user.rb'
require_relative 'models/tag.rb'
require_relative 'models/tagTweet.rb'

get '/' do
    '<h1>hello<h1>'
end