class AddNullconstraintsToWorkShifts < ActiveRecord::Migration
  def change
    change_column :work_shifts, :start_time, :datetime, :null => false
    change_column :work_shifts, :duration, :integer, :null => false
    change_column :work_shifts, :user_id, :integer, :null => false
  end
end
