class Tweet < ActiveRecord::Base
    belongs_to :user

    has_many :tag_tweets
    has_many :tags, through: :tag_tweets

    has_many :mentions
    has_many :mention_users, through: :mentions, source: :user
end