class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :text
      t.datetime :create_time
      t.integer :user_id
    end
  end
end
