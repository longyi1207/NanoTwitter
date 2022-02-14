class TweetReply < ActiveRecord::Base
    belongs_to :tweet
    belongs_to :reply, class_name: :"Tweet"
end