class CreateTagTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tag_tweets do |t|
      t.integer :tag_id
      t.integer :tweet_id
      t.datetime :create_time
    end
  end
end
