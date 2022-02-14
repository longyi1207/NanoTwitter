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
  it "get_users" do
    get '/users'
    last_response.ok?
    puts last_response.body
    assert_equal last_response.body, []
  end

  it "create_user" do
    post '/newUser'
    assert_equal last_response.status, 200
  end

  it "delete_user" do
    delete '/users'
    assert_equal last_response.status, 200
  end
end

# describe 'Tweet' do
#   it "get_tweets" do
#     get '/tweets'
#       last_response.ok?
#       puts last_response.body
#       assert_equal last_response.body, []
#   end

#   it "create_tweet" do
#     post '/tweet'
#       last_response.ok?
#       puts last_response.body
#       assert_equal last_response.body, []
#   end
# end

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