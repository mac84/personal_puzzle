class AddArchivedToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :archived, :boolean, :default => false
  end
end
