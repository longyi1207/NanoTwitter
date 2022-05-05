# General
## get '/'
Entry point.

## get '/home'
Redirect to home page.

# Login & logout
## get '/login'
Redirect to login page.

## get '/logout'
Logout!

## post '/login'
Submit login request.

# New user
## get '/users/new'
Redirect to create user page.

## post '/users/new'
Create new user.

# Following & follower
## get '/users/follow/:flag'
Redirect to following & follower page.

## post "/users/doFollow"
Follow a user.

## post "/users/doUnfollow"
Unfollow a user.

## post "/users/getMoreFollowers"
Load more followers.

## post "/users/getMoreFollowing"
Load more followings.

# Tweet
## post '/tweet/like'
Like a Tweet.

## post '/tweet/retweet'
Retweet a Tweet.

## post '/tweet/new'
Post a new Tweet.

## post "/tweet/getMoreTimeline"
Load more Tweets in timeline.

# Search
## get '/search'
Search!

# Test
## get '/test/readCsv'
Prepare data.

## get '/test/reset' 
Clear all data and load test data.

## get "/test/tweet"
Test posting Tweets.

## get "/test/status" 
Status check.

## get "/test/corrupted"
Corruption check.

## get "/test/stress"
Stress test.

## get "/test/performance"
Perfomance test.



