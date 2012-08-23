class ChangeStartTimeOnWorkedShifts < ActiveRecord::Migration
  def up
    change_column :work_shifts, :start_time, :time, :null => false
  end

  def down
    change_column :work_shifts, :start_time, :datetime, :null => false
  end
end
