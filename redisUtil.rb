module RedisUtil

    def cacheUseridExist?(userid)
        REDIS.with do |conn|
            check = conn.exists("followees:#{userid}")
            if check == 1
                return true
            else
                return false
            end
        end
        return false
    end

    def cacheFetchAllFollowees(userid)
        REDIS.with do |conn|
            followee_id = conn.lrange("followees:#{userid}", 0, -1)
            return followee_id
        end
        return []
    end

    def cacheAddFollowee(userid, followeeid)
        REDIS.with do |conn|
            conn.rpush("followees:#{userid}", followeeid)
        end
    end
end