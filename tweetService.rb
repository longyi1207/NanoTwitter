# require 'redis'

module TweetService

    logger = Logger.new($stdout)

    def fetchTimeline(userid)
        start_time = Time.now()
        if REDIS.exists("followees:#{userid}") == 1
            followee_id = REDIS.lrange("followees:#{userid}", 0, -1)
            logger.info("fetch followee ids #{followee_id} from redis")
        else
            followee = UserFollower.where("follower_id="+userid.to_s).all
            followee_id = []
            followee.each do |f|
                followee_id.append(f["user_id"])
                REDIS.rpush("followees:#{userid}", f["user_id"])
            end
            logger.info("Cache followee ids #{followee_id} into redis")
        end

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
        logger.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")
        return user_names, tweet
    end

    # body = "hi asd #emem @ads #aa dasda @"
    def doTweet(text, userid)
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