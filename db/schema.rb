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

ActiveRecord::Schema.define(version: 2022_02_06_221438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tag_tweets", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "tweet_id"
    t.datetime "create_time", precision: 6
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "text"
    t.datetime "create_time", precision: 6
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.datetime "create_time", precision: 6
  end

end
