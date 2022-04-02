module RedisUtil
    # Keys
    def redisKeyFollowees(userid) 
        return "followees:#{userid}"
    end

    def redisKeyFollowers(userid)
        return "followers:#{userid}"
    end


    # wrapper
    def cacheKeyExist?(key)
        REDIS.with do |conn|
            check = conn.exists(key)
            if check == 1
                return true
            else
                return false
            end
        end
        LOGGER.error("#{self.class}##{__method__}--> Redis error")
        return false
    end

    def cacheListRange(key, from, to)
        REDIS.with do |conn|
            followee_id = conn.lrange(key, from, to)
            return followee_id
        end
        LOGGER.error("#{self.class}##{__method__}--> Redis error")
        return []
    end

    def cacheListRightPush(key, value)
        REDIS.with do |conn|
            conn.rpush(key, value)
        end
    end

    def cacheListBulkPush(key, list)
        REDIS.with do |conn|
            conn.pipelined do |pipeline|
                list.each do |value|
                    pipeline.rpush(key, value)
                end
            end
        end
    end

    def cacheListRemove(key, value)
        REDIS.with do |conn|
            conn.lrem(key, 0, value)
        end
    end

    def cacheListLength(key)
        REDIS.with do |conn|
            conn.llen(key)
        end
    end
end