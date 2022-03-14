# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_07_225814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
    t.integer "tweet_user_id"
    t.datetime "create_time"
  end

  create_table "mentions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
    t.integer "tweet_user_id"
    t.datetime "create_time"
  end

  create_table "retweets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
    t.integer "tweet_user_id"
    t.datetime "create_time"
  end

  create_table "tag_tweets", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "tweet_id"
    t.datetime "create_time"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
  end

  create_table "tweet_replies", force: :cascade do |t|
    t.string "text"
    t.integer "tweet_id"
    t.integer "user_id"
    t.integer "reply_id"
    t.integer "reply_user_id"
    t.datetime "create_time"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "text"
    t.datetime "create_time"
    t.integer "user_id"
    t.integer "likes_counter"
    t.integer "retweets_counter"
    t.integer "parent_tweet_id"
    t.integer "original_tweet_id"
  end

  create_table "user_followers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "follower_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.datetime "create_time"
  end

end
