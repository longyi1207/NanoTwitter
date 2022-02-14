class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t|
      t.integer :user_id
      t.integer :tweet_id
      t.integer :tweet_user_id
      t.datetime :create_time
    end
  end
end
