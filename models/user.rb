class User < ActiveRecord::Base
    has_many :tweets

    has_many :user_followers
    has_many :followers, through: :user_followers
    has_many :inverse_user_followers, class_name: :"UserFollower", foreign_key: :"follower_id"
    has_many :inverse_followers, through: :inverse_user_followers, source: :user

    has_many :mentions
    has_many :mention_tweets, through: :mentions, source: :tweet
end