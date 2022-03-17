module TweetService 
    def fetchTimeline(userid)
        followee = UserFollower.where("follower_id="+userid.to_s).all
        followee_id = []
        followee.each do |f|
            followee_id.append(f["user_id"])
        end

        if followee_id.length==0
            tweet = []
        else
            tweet = Tweet.where("user_id=any(array"+ followee_id.to_s+")").order("create_time DESC").limit(50)
        end

        user_names = []
        tweet.each do |t|
            user_names.append(User.find(t["user_id"]).name)
        end
        return user_names, tweet
    end

    def doTweet(text, userid)
        tweet= Tweet.create(text:text, user_id:userid, likes_counter:0, retweets_counter:0, parent_tweet_id:0, original_tweet_id:0, create_time:Time.now())
        return tweet
    end

    def getTweet(tweetid)
        tweet = Tweet.where(id:tweetid).first
        return tweet
    end
end