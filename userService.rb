require "bcrypt"

module UserService
    include BCrypt

    # Create user
    def createUser(params = {})
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

        return true, user.slice(:id, :name)
    end

    # Follow a user
    def followUser(myid, userid)
        check = UserFollower.where(user_id: userid, follower_id: myid)
        if check != nil
            UserFollower.create(user_id: userid, follower_id: myid)
        end
        true
    end

    # Unfollow a user
    def unfollowUser(myid, userid)
        UserFollower.delete_by(user_id: userid, follower_id: myid)
        true
    end

    # Get number of followings and followers
    def getFollowerCount(userid)
        followingCount = UserFollower.where(follower_id: userid).count
        followerCount = UserFollower.where(user_id: userid).count
        return followingCount, followerCount
    end

    # Get folowers following to userid
    def getFollowers(userid, offset, limit)
        sql = %{select a.id, name, fid, COALESCE(follower_id, 0) as followed from (
            select users.*, f.id as fid from 
            (SELECT follower_id, user_followers.id FROM users
            INNER JOIN user_followers ON user_followers.user_id = users.id WHERE users.id = #{userid}) as f 
            inner join users on f.follower_id = users.id 
            where f.id > #{offset} limit #{limit}) as a
            left join user_followers on a.id = user_followers.user_id and follower_id = #{userid}
            order by id asc
            }
        ActiveRecord::Base.connection.execute(sql)
    end

    # Get users followed by userid
    def getFollowing(userid, offset, limit)
        sql = %{select users.id, users.name, f.id as fid from 
            (SELECT user_id, user_followers.id FROM users
            INNER JOIN user_followers ON user_followers.follower_id = users.id WHERE users.id = #{userid}) as f 
            inner join users on f.user_id = users.id 
            where f.id > #{offset}
            order by id asc limit #{limit}
            }
        ActiveRecord::Base.connection.execute(sql)
    end
end