class Tweet < ActiveRecord::Base
    belongs_to :user
    has_many :tag_tweets
    has_many :tags, through: :tag_tweets
end