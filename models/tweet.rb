class Tweet < ActiveRecord::Base
    belongs_to :user

    has_many :tag_tweets
    has_many :tags, through: :tag_tweets

    has_many :mentions
    has_many :mention_users, through: :mentions, source: :user

    has_many :likes
    has_many :like_users, through: :likes, source: :user

    has_many :retweets
    has_many :retweet_tweets, through: :retweets, source: :tweet

    has_many :replies
    has_many :reply_tweets, through: :replies, source: :tweet

    has_many :tweet_replies
    has_many :replies, through: :tweet_replies
    has_many :inverse_tweet_replies, class_name: :"TweetReply", foreign_key: :"reply_user_id"
    has_many :inverse_replies, through: :inverse_tweet_replies, source: :tweet
end