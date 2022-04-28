module TweetService

    def fetchTimeline(userid, offset, limit)
        start_time = Time.now()
        tweet = []
        if cacheKeyExist?(redisKeyTimeline(userid))
            tweetIds = cacheSSetRange(redisKeyTimeline(userid), offset, offset+limit-1)
            tweet = Tweet.joins(:user).select("tweets.*, users.name").where("tweets.id=any(array"+ tweetIds.to_s.gsub("\"","")+")").order("tweets.create_time DESC") 
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")

        return tweet
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