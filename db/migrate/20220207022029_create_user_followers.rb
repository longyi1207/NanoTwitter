class CreateUserFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_followers do |t|
      t.integer :user_id
      t.integer :follower_id
    end
  end
end
