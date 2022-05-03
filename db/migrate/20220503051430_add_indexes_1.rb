class AddIndexes1 < ActiveRecord::Migration[7.0]
  def change
      add_index :tweets, :create_time
  end
end
