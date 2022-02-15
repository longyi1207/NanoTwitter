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
    puts "User test running successfully"
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
    puts "Tweet test running successfully"
  end
end


describe 'Tag' do
  it "create_tags" do
    post '/newTag'
    last_response.ok?
    get '/tagCount'
    assert_equal "1", last_response.body
  end

  it "delete_tag" do
    delete '/tags'
      last_response.ok?
      get '/tagCount'
      assert_equal "0", last_response.body
      puts "Tag test running successfully"
  end
end


describe 'Retweet' do
  it "create_retweet" do
    post '/newRetweet'
    last_response.ok?
    get '/retweetCount'
    assert_equal "1", last_response.body
  end

  it "delete_retweet" do
    delete '/retweets'
      last_response.ok?
      get '/retweetCount'
      assert_equal "0", last_response.body
      puts "Retweet test running successfully"
  end
end


describe 'tweetReply' do
  it "create_tweetReply" do
    post '/newTweetReply'
    last_response.ok?
    get '/tweetReplyCount'
    assert_equal "1", last_response.body
  end

  it "delete_tag" do
    delete '/tweetReplies'
      last_response.ok?
      get '/tweetReplyCount'
      assert_equal "0", last_response.body
      puts "tweetReply test running successfully"
  end
end