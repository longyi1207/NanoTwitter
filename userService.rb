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
    end

    # Unfollow a user
    def unfollowUser(myid, userid)
        UserFollower.delete_by(user_id: userid, follower_id: myid)
    end

    # Get number of followings and followers
    def getFollowerCount(userid)
        followingCount = UserFollower.where(follower_id: userid).count
        followerCount = UserFollower.where(user_id: userid).count
        return followingCount, followerCount
    end
end