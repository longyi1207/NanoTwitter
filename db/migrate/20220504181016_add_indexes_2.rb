class AddIndexes2 < ActiveRecord::Migration[7.0]
  def change
      add_index :users, :create_time
  end
end
