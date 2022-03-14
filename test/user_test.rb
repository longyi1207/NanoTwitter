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

describe "service_function" do
  User.destroy_all
  UserFollower.destroy_all

  user1 = User.create(name: "u1")
  user2 = User.create(name: "u2") 

  it "getFollowerCount" do
    followingCount, followerCount = getFollowerCount(user1.id)
    assert_equal 0, followingCount
    assert_equal 0, followerCount
  end

  it "followUser" do
    followUser(user1.id, user2.id)
    followingCount, followerCount = getFollowerCount(user1.id)
    assert_equal 1, followingCount
    assert_equal 0, followerCount
    followUser(user2.id, user1.id)
    followingCount, followerCount = getFollowerCount(user1.id)
    assert_equal 1, followingCount
    assert_equal 1, followerCount
    UserFollower.destroy_all
  end

  it "unfollowUser" do
    followUser(user1.id, user2.id)
    followUser(user2.id, user1.id)
    unfollowUser(user1.id, user2.id)
    followingCount, followerCount = getFollowerCount(user1.id)
    assert_equal 0, followingCount
    assert_equal 1, followerCount
    unfollowUser(user2.id, user1.id)
    followingCount, followerCount = getFollowerCount(user1.id)
    assert_equal 0, followingCount
    assert_equal 0, followerCount
    UserFollower.destroy_all
  end
end