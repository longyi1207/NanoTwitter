module RedisUtil
    # Keys
    def redisKeyFollowees(userid) 
        return "followees:#{userid}"
    end

    def redisKeyFollowers(userid)
        return "followers:#{userid}"
    end

    def redisKeySearch(key) 
        return "search:#{key}"
    end

    def redisKeySearchUsers(key) 
        return "searchUsers:#{key}"
    end

    def redisKeyTimeline(userid) 
        return "timeline:#{userid}"
    end

    def redisKeyUsernames(userid)
        return "timeline_usernames:#{userid}"
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

    # list
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

    # sorted set
    def cacheSSetRange(key, from, to)
        REDIS.with do |conn|
            followee_id = conn.zrange(key, from, to)
            return followee_id
        end
        LOGGER.error("#{self.class}##{__method__}--> Redis error")
        return []
    end

    def cacheSSetAdd(key, value)
        REDIS.with do |conn|
            conn.zadd(key, value.to_i, value)
        end
    end

    def cacheSSetBulkAdd(key, list)
        REDIS.with do |conn|
            conn.pipelined do |pipeline|
                list.each do |value|
                    if value.is_a?(Hash)
                        pipeline.zadd(key, value['rank'], value['member'])
                    else
                        pipeline.zadd(key, value.to_i, value)
                    end
                end
            end
        end
    end

    def cacheSSetBulkAddGeneral(list)
        REDIS.with do |conn|
            conn.pipelined do |pipeline|
                list.each do |value|
                    pipeline.zadd(value['key'], value['rank'], value['member'])
                end
            end
        end
    end

    def cacheSSetRemove(key, value)
        REDIS.with do |conn|
            conn.zrem(key, value)
        end
    end

    def cacheSSetSize(key)
        REDIS.with do |conn|
            conn.zcard(key)
        end
    end

    def cacheSSetBulkCheck(key, list)
        REDIS.with do |conn|
            conn.pipelined do |pipeline|
                list.each do |value|
                    pipeline.zrank(key, value)
                end
            end
        end
    end
end