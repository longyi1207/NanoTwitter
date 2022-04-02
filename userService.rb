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
        return true, user.slice(:id, :name)
    end

    # Follow a user
    # myid follow userid
    def followUser(myid, userid)
        start_time = Time.now()
        check = UserFollower.where(user_id: userid, follower_id: myid).first
        if !check
            UserFollower.create(user_id: userid, follower_id: myid)
            cacheListRightPush(redisKeyFollowees(myid), userid)
            cacheListRightPush(redisKeyFollowers(userid), myid)
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
            cacheListRemove(redisKeyFollowees(myid), userid)
            cacheListRemove(redisKeyFollowers(userid), myid)
        end
        LOGGER.info("#{self.class}##{__method__}--> myid=#{myid},userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS") 
        true
    end

    # Get number of followings and followers
    def getFollowerCount(userid)
        start_time = Time.now()
        followingCount = cacheListLength(redisKeyFollowees(userid))
        followerCount = cacheListLength(redisKeyFollowers(userid))
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS") 
        return followingCount, followerCount
    end

    # Get folowers following to userid
    def getFollowers(userid, offset, limit)
        start_time = Time.now()
        sql = %{select a.id, name, fid, COALESCE(follower_id, 0) as followed from (
            select users.*, f.id as fid from 
            (SELECT follower_id, user_followers.id FROM users
            INNER JOIN user_followers ON user_followers.user_id = users.id WHERE users.id = #{userid}) as f 
            inner join users on f.follower_id = users.id 
            where f.id > #{offset} limit #{limit}) as a
            left join user_followers on a.id = user_followers.user_id and follower_id = #{userid}
            order by fid asc
            }
        result = ActiveRecord::Base.connection.execute(sql)
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},offset=#{offset},limit=#{limit} TIME COST: #{Time.now()-start_time} SECONDS")
        result 
    end

    # Get users followed by userid
    def getFollowing(userid, offset, limit)
        start_time = Time.now()
        sql = %{select users.id, users.name, f.id as fid from 
            (SELECT user_id, user_followers.id FROM users
            INNER JOIN user_followers ON user_followers.follower_id = users.id WHERE users.id = #{userid}) as f 
            inner join users on f.user_id = users.id 
            where f.id > #{offset}
            order by f.id asc limit #{limit}
            }
        result = ActiveRecord::Base.connection.execute(sql)
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},offset=#{offset},limit=#{limit} TIME COST: #{Time.now()-start_time} SECONDS")
        result 
    end

    # Load followee ids into redis
    # return followee list if needReturn is true
    def fetchAllFollowee(userid, needReturn)
        start_time = Time.now()
        followee_id = []
        if cacheKeyExist?(redisKeyFollowees(userid))
            if needReturn
                followee_id = cacheListRange(redisKeyFollowees(userid), 0, -1)
            end
        else
            followee = UserFollower.where("follower_id="+userid.to_s).all
            followee.each do |f|
                followee_id.append(f["user_id"])
            end
            cacheListBulkPush(redisKeyFollowees(userid), followee_id)
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},needReturn=#{needReturn} TIME COST: #{Time.now()-start_time} SECONDS")
        if needReturn
            return followee_id
        end
    end

    def fetchAllFollower(userid, needReturn)
        start_time = Time.now()
        follower_id = []
        if cacheKeyExist?(redisKeyFollowers(userid))
            if needReturn
                follower_id = cacheListRange(redisKeyFollowers(userid), 0, -1)
            end
        else
            follower = UserFollower.where("user_id="+userid.to_s).all
            follower.each do |f|
                follower_id.append(f["follower_id"])
            end
            cacheListBulkPush(redisKeyFollowees(userid), follower_id)
        end
        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid},needReturn=#{needReturn} TIME COST: #{Time.now()-start_time} SECONDS")
        if needReturn
            return follower_id
        end
    end

    # All jobs need to be done when a user login
    def doOnLogin(userid)
        start_time = Time.now()
        # Load redis keys
        fetchAllFollowee(userid, false)
        fetchAllFollower(userid, false)

        LOGGER.info("#{self.class}##{__method__}--> userid=#{userid} TIME COST: #{Time.now()-start_time} SECONDS")
    end
end