class User < ActiveRecord::Base
    has_many :tweet
end