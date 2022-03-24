module TweetService
    logger = Logger.new($stdout)

    def fetchTimeline(userid)
        start_time = Time.now()
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
        logger.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")
        return user_names, tweet
    end

    # body = "hi asd #emem @ads #aa dasda @"
    def parseTweet(text, userid)
        start_time = Time.now()
        body = text.split()
        body.each do |t|
            if t.length > 1
                if t[0]=="#"
                    Tag.create()
                    TagTweet.create()
                elsif t[0]=="@"
                    Mention.create()
                end
            end

        end
        tweet= Tweet.create(text:text, user_id:userid, likes_counter:0, retweets_counter:0, parent_tweet_id:0, original_tweet_id:0, create_time:Time.now())
        logger.info("#{self.class}##{__method__}--> tweetid=#{tweet.id} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end

    def getTweet(tweetid)
        start_time = Time.now()
        tweet = Tweet.where(id:tweetid).first
        logger.info("#{self.class}##{__method__}--> tweetid=#{tweetid} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end
end