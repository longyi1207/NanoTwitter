class AddIndexes < ActiveRecord::Migration[7.0]
  def change
      add_index :users, :name
      add_index :tweets, :user_id
      add_index :user_followers, :user_id
      add_index :user_followers, :follower_id
  end
end
