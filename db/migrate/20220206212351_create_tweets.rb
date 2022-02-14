class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :text
      t.datetime :create_time
      t.integer :user_id
      t.integer :likes_counter
      t.integer :retweets_counter
      t.integer :parent_tweet_id
      t.integer :original_tweet_id
    end
  end
end
