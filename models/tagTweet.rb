class TagTweet < ActiveRecord::Base
    belongs_to :tag
    belongs_to :tweet
end