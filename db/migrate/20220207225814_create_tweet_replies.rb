class CreateTweetReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :tweet_replies do |t|
      t.integer :tweet_id
      t.integer :user_id
      t.integer :reply_id
      t.integer :reply_user_id
      t.datetime :create_time
    end
  end
end
