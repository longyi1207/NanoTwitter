class AddIndexes3 < ActiveRecord::Migration[7.0]
  def change
      add_index :likes, [:user_id, :tweet_id]
      add_index :user_followers, [:user_id, :follower_id]
  end
end
