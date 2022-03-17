require_relative 'models/user.rb'
require_relative 'models/userFollower.rb'
require_relative 'models/tweet.rb'

module TestService
    def userCorrupted?(userid)
        user = User.where(id:userid).first
        if user == nil
            return false
        end
        followings = UserFollower.where(follower_id:userid)
        followings.each do |f|
            f_id = f.user_id
            f_user = User.where(id:f_id).first
            if f_user == nil
                return false
            end
        end
        true
    end

    def tweetCorrupted?(tweet)
        if tweet.text == nil || tweet.text == "" || tweet.user_id == nil || tweet.likes_counter == nil || tweet.retweets_counter == nil || tweet.create_time == nil
            return false
        end
        true
    end
end