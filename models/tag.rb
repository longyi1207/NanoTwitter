class Tag < ActiveRecord::Base
    has_many :tag_tweets
    has_many :tweets, through: :tag_tweets
end