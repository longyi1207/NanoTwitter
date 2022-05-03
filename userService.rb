require "bcrypt"

module UserService
    include BCrypt

    # Create user
    def createUser(params = {})
        start_time = Time.now()
        if params[:username].blank? || params[:password1].blank? || params[:password2].blank?
            return false, "Please provide required information!"
        end

        if params[:password1] != params[:password2]
            return false, "Passwords do not match!"
        end
        

        password_hash = Password.create(params[:password1])
        user = User.where(name: params[:username]).first
        if user != nil
            return false, "User already exists!"
        end

        user = User.create(name: params[:username], password: password_hash, create_time:Time.now())
        LOGGER.info("#{self.class}##{__method__}--> params=#{params} TIME COST: #{Time.now()-start_time} SECONDS")  
        return true, user.slice(:id, :name, :create_time)
    end

    # Follow a user
    # myid follow userid
    def followUser(myid, userid)
        start_time = Time.now()
        check = UserFollower.where(user_id: userid, follower_id: myid).first
        if !check
            UserFollower.create(user_id: userid, follower_id: myid)
            cacheSSetAdd(redisKeyFollowees(myid), userid)
            if cacheKeyExist?(redisKeyFollowers(userid))
                cacheSSetAdd(redisKeyFollowers(userid), myid)
            end
            # add tweets to timeline
            followTimeline(myid, userid, 1000)
        end
        LOGGER.info("#{self.class}##{__method__}--> myid=#{myid},userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS") 
        true
    end

    # Unfollow a user
    def unfollowUser(myid, userid)
        start_time = Time.now()
        puts myid
        puts userid
        check = UserFollower.where(user_id: userid, follower_id: myid).first
        puts check
        if check
            UserFollower.delete_by(user_id: userid, follower_id: myid)
            cacheSSetRemove(redisKeyFollowees(myid), userid)
            cacheSSetRemove(redisKeyFollowers(userid), myid)

            unfollowTimeline(myid, userid, 1000)
        end
        LOGGER.info("#{self.class}##{__method__}--> myid=#{myid},userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS") 
        true
    end

    # Get number of followings and followers
    def getFollowerCount(userid)
        # start_time = Time.now()
        followingCount = cacheSSetSize(redisKeyFollowees(userid))
        followerCount = cacheSSetSize(redisKeyFollowers(userid))
        # LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS") 
        return followingCount, followerCount
    end

    # Get folowers following to userid
    def getFollowers(userid, offset, limit)
        start_time = Time.now()
        followerId = cacheSSetRange(redisKeyFollowers(userid), offset, offset+limit-1)
        result = []
        if followerId.length > 0
            followers = User.select(:id, :name).where("id=any(array"+ followerId.to_s.gsub("\"","")+")")
            checkList = cacheSSetBulkCheck(redisKeyFollowers(userid), followerId)
            index = offset
            followers.zip(checkList).each do |f, c|
                wrapper = {}
                wrapper["id"] = f.id
                wrapper["name"] = f.name
                wrapper["fid"] = index
                if c
                    wrapper["followed"] = 1
                else
                    wrapper["followed"] = 0
                end
                result.append(wrapper)
                index += 1
            end
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},offset=#{offset},limit=#{limit} TIME COST: #{Time.now()-start_time} SECONDS")
        result 
    end

    # Get users followed by userid
    def getFollowing(userid, offset, limit)
        start_time = Time.now()
        followingId = cacheSSetRange(redisKeyFollowees(userid), offset, offset+limit-1)
        result = []
        if followingId.length > 0
            followees = User.select(:id, :name).where("id=any(array"+ followingId.to_s.gsub("\"","")+")")
            index = offset
            followees.each do |f|
                wrapper = {}
                wrapper["id"] = f.id
                wrapper["name"] = f.name
                wrapper["fid"] = index
                result.append(wrapper)
                index += 1
            end
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},offset=#{offset},limit=#{limit} TIME COST: #{Time.now()-start_time} SECONDS")
        result 
    end

    # Load followee ids into redis
    # return followee list if needReturn is true
    def fetchAllFollowee(userid, needReturn)
        # start_time = Time.now()
        followee_id = []
        if cacheKeyExist?(redisKeyFollowees(userid))
            if needReturn
                followee_id = cacheSSetRange(redisKeyFollowees(userid), 0, -1)
            end
        else
            followee = UserFollower.where("follower_id="+userid.to_s).all
            followee.each do |f|
                followee_id.append(f["user_id"])
            end
            cacheSSetBulkAdd(redisKeyFollowees(userid), followee_id)
        end
        # LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},needReturn=#{needReturn} TIME COST: #{Time.now()-start_time} SECONDS")
        if needReturn
            return followee_id
        end
    end

    def fetchAllFollower(userid, needReturn)
        start_time = Time.now()
        follower_id = []
        if cacheKeyExist?(redisKeyFollowers(userid))
            if needReturn
                follower_id = cacheSSetRange(redisKeyFollowers(userid), 0, -1)
            end
        else
            follower = UserFollower.where("user_id="+userid.to_s).all
            follower.each do |f|
                follower_id.append(f["follower_id"])
            end
            cacheSSetBulkAdd(redisKeyFollowers(userid), follower_id)
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},needReturn=#{needReturn} TIME COST: #{Time.now()-start_time} SECONDS")
        if needReturn
            return follower_id
        end
    end

    def warmTimelineCache(userid, followee_id, limit)
        start_time = Time.now()
        if cacheKeyExist?(redisKeyTimeline(userid))
            return
        end
        user_list = [userid]
        if followee_id.length > 0
            user_list += followee_id
        end
        cache_list = []
        tweet = Tweet.where("user_id=any(array"+ user_list.to_s.gsub("\"","")+")").order("create_time DESC").limit(limit)
        tweet.each do |t|
            kv = {'rank'=>-t['create_time'].to_i, 'member'=>t['id']}
            cache_list.append(kv)
        end
        cacheSSetBulkAdd(redisKeyTimeline(userid), cache_list)
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},followee_id=#{followee_id},limit=#{limit} TIME COST: #{Time.now()-start_time} SECONDS")
    end

    # All jobs need to be done when a user login
    def doOnLogin(userid)
        start_time = Time.now()
        # Load redis keys
        followee_id = fetchAllFollowee(userid, true)
        fetchAllFollower(userid, false)
        warmTimelineCache(userid, followee_id, 1000)

        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")
    end
end