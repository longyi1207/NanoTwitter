ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'minitest/autorun'
require 'rack/test'
require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
include Rack::Test::Methods

def app
  Sinatra::Application
end


describe 'User' do
  it "create_user" do
    post '/newUser'
    last_response.ok?
    get '/userCount'
    assert_equal "1", last_response.body
  end

  it "delete_user" do
    delete '/users'
    last_response.ok?
    get '/userCount'
    assert_equal "0", last_response.body
  end
end

describe 'Tweet' do
  it "create_tweet" do
    post '/newTweet'
    last_response.ok?
    get '/tweetCount'
    assert_equal "1", last_response.body
  end

  it "delete_tweet" do
    delete '/tweets'
    last_response.ok?
    get '/tweetCount'
    assert_equal "0", last_response.body
  end
end

# describe 'Tag' do
#   it "get_tags" do
#     get '/tags'
#       last_response.ok?
#       puts last_response.body
#       assert_equal last_response.body, []
#   end

#   it "post_tag" do
#     post '/tag'
#       last_response.ok?
#       puts last_response.body
#       assert_equal last_response.body, []
#   end
# end