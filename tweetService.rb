module TweetService

    def fetchTimeline(userid, offset, limit)
        # including offset
        start_time = Time.now()
        tweet = []
        if cacheKeyExist?(redisKeyTimeline(userid))
            tweetIds = cacheSSetRange(redisKeyTimeline(userid), offset, offset+limit-1)
            if !tweetIds.empty?
                tweet = Tweet.joins(:user).select("tweets.*, users.name").where("tweets.id=any(array"+ tweetIds.to_s.gsub("\"","")+")").order("tweets.create_time DESC")
            end 
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")

        return tweet
    end

    # modify timeline when follow a user
    def followTimeline(myid, userid, limit)
        # check timeline cache
        if cacheKeyExist?(redisKeyTimeline(myid))
            # get the last Tweet timestamp
            last_timestamp = cacheSSetRange(redisKeyTimeline(myid), -1, -1, :withscores => true)[0][1]
            # convert timestamp to time
            last_time = Time.at(-last_timestamp).utc
            # get all Tweets from userid, create_time > last_time, limit 1000
            tweet_list = Tweet.where("create_time > ?", last_time).where(user_id: userid).order("create_time DESC").limit(limit)
            # put all tweets into cache
            cache_list = []
            tweet_list.each do |t|
                kv = {'rank'=>-t['create_time'].to_i, 'member'=>t['id']}
                cache_list.append(kv)
            end
            if !cache_list.empty?
                cacheSSetBulkAdd(redisKeyTimeline(myid), cache_list)
                # keep limit entries in cache
                cacheSSetRemRangeByRank(redisKeyTimeline(myid), limit, -1)
            end
        else
            # just add all Tweets
            cache_list = []
            tweet = Tweet.where(user_id: userid).order("create_time DESC").limit(limit)
            tweet.each do |t|
                kv = {'rank'=>-t['create_time'].to_i, 'member'=>t['id']}
                cache_list.append(kv)
            end
            cacheSSetBulkAdd(redisKeyTimeline(myid), cache_list)
        end
    end

    def unfollowTimeline(myid, userid, limit)
        cacheKeyDelete(redisKeyTimeline(myid))
        followee_id = fetchAllFollowee(myid, true)
        user_list = [myid]
        if followee_id.length > 0
            user_list += followee_id
        end
        cache_list = []
        tweet = Tweet.where("user_id=any(array"+ user_list.to_s.gsub("\"","")+")").order("create_time DESC").limit(limit)
        tweet.each do |t|
            kv = {'rank'=>-t['create_time'].to_i, 'member'=>t['id']}
            cache_list.append(kv)
        end
        cacheSSetBulkAdd(redisKeyTimeline(myid), cache_list)
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
        fanout(tweet, userid)
        LOGGER.info("#{self.class}##{__method__}--> tweetid=#{tweet.id} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end

    def fanout(tweet, userid)
        start_time = Time.now()
        user_list = [userid]
        follower_id = fetchAllFollower(userid, true)
        if follower_id.length > 0
            user_list += follower_id
        end
        fanout_list = []
        user_list.each do |f|
            wrapper = {}
            if cacheKeyExist?(redisKeyTimeline(f))
                wrapper['key'] = redisKeyTimeline(f)
                wrapper['rank'] = -tweet.create_time.to_i
                wrapper['member'] = tweet.id
                fanout_list.append(wrapper)
            end
        end
        cacheSSetBulkAddGeneral(fanout_list)
        LOGGER.info("#{self.class}##{__method__}--> tweetid=#{tweet.id} TIME COST: #{Time.now()-start_time} SECONDS") 
    end

    def getTweet(tweetid)
        start_time = Time.now()
        tweet = Tweet.where(id:tweetid).first
        LOGGER.info("#{self.class}##{__method__}--> tweetid=#{tweetid} TIME COST: #{Time.now()-start_time} SECONDS") 
        return tweet
    end

    def doLike(myid, userid, tweetid) 
        start_time = Time.now()
        check = Like.where(user_id: myid, tweet_id: tweetid).first
        counter = -1
        if !check
            # insert new like record
            Like.create(user_id: myid, tweet_id: tweetid, tweet_user_id: userid, create_time: Time.now)
            # update like counter
            counter = Tweet.find(tweetid).likes_counter
            if counter == nil
                counter = 1
            else
                counter += 1
            end
            Tweet.find(tweetid).update_attribute(:likes_counter,counter);
        end
        LOGGER.info("#{self.class}##{__method__}--> myid=#{myid},userid=#{userid},tweetid=#{tweetid} TIME COST: #{Time.now()-start_time} SECONDS")
        return counter
    end

    def doSearch(phrase, paged)
        @key=phrase
        if paged!=nil
            if session[:toId]!=0
                session[:toId] = session[:toId]+50
            else
                session[:toId] = 100
            end
            tweets = Tweet.where("text like '%"+@key+"%'").limit(session[:toId])[session[:toId]-50..session[:toId]]
            userIds = tweets.pluck("user_id")
            @users = []
            userIds.each do |id|
                @users << User.find(id).name
            end
            tweetIds = tweets.pluck("id")
        else
            session[:toId] = 0
            if cacheKeyExist?(redisKeySearch(@key))
                tweetIds = cacheSSetRange(redisKeySearch(@key), 0, -1)
                @users = cacheSSetRange(redisKeySearchUsers(@key), 0, -1)
            else
                tweets = Tweet.where("text like '%"+@key+"%'").limit(50)
                userIds = tweets.pluck("user_id")
                @users = []
                userIds.each do |id|
                    @users << User.find(id).name
                end
                cacheSSetBulkAdd(redisKeySearch(@key), tweets.ids)
                cacheSSetBulkAdd(redisKeySearchUsers(@key), @users)
            end
        end
        if !tweetIds
            @result = []
        else
            @result = Tweet.find(tweetIds)
        end
        LOGGER.info(@result)
        return @result, @users, @key
    end

    def doRetweet(myid, userid, tweetid)
        start_time = Time.now()
        counter = -1
        if myid.to_s != userid.to_s
            check = Retweet.where(user_id: myid, tweet_id: tweetid).first
            if !check
                tweet = Tweet.find(tweetid)
                #send tweet
                response = TWEETAPP.get("/api/tweet/new") do |req|
                    req.params = {text: tweet.text, userid: myid}
                end
                if response.status == 200
                    Retweet.create(user_id: myid, tweet_id: tweetid, tweet_user_id: userid, create_time: Time.now)
                    counter = tweet.retweets_counter
                    if counter == nil
                        counter = 1
                    else
                        counter += 1
                    end
                    tweet.update_attribute(:retweets_counter,counter);
                end
            end
        end
        LOGGER.info("#{self.class}##{__method__}--> myid=#{myid},userid=#{userid},tweetid=#{tweetid} TIME COST: #{Time.now()-start_time} SECONDS")
        return counter
    end
end