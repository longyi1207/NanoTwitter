ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "test_relation" do
  it "generate_rows" do
    get '/testing'
      last_response.ok?
      # for user in User.all do
      #   puts user.name
      # end
      
    # delete '/testing'
  end
end