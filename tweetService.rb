module TweetService

    def fetchTimeline(userid)
        start_time = Time.now()
        followee_id = fetchAllFollowee(userid, true)

        if followee_id.length==0
            tweet = []
        else
            tweet = Tweet.where("user_id=any(array"+ followee_id.to_s.gsub("\"","")+")").order("create_time DESC").limit(50)
        end

        user_names = []
        if tweet.length>0
            tweet.each do |t|
                user_names.append(User.find(t["user_id"]).name)
            end
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")
        return user_names, tweet
    end

    # body = "hi asd #emem @ads #aa dasda @"
    def doTweet(text, userid)
        start_time = Time.now()
        body = text.split()
        tweet= Tweet.create(text:text, user_id:userid, likes_counter:0, retweets_counter:0, parent_tweet_id:0, original_tweet_id:0, create_time:Time.now())
        body.each do |t|
            if t.length > 1
                if t[0]=="#"
                    t = Tag.create(t[1..-1])
                    TagTweet.create(tag_id:t.id, tweet_id:tweet.id, create_time:Time.now())
                elsif t[0]=="@"
                    # if 
                    # Mention.create(user_id=)
                end
            end

        end
        
        LOGGER.info("#{self.class}##{__method__}--> tweetid=#{tweet.id} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end

    def getTweet(tweetid)
        start_time = Time.now()
        tweet = Tweet.where(id:tweetid).first
        LOGGER.info("#{self.class}##{__method__}--> tweetid=#{tweetid} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end
end