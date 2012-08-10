class AddIdsToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :user_id, :integer
    add_column :tasks, :client_id, :integer
  end
end
