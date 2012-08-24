class AddUserIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :user_id, :integer
    change_column :clients, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :clients, :user_id
  end
end
