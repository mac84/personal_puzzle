class AddMinScheduleShiftLengthToUser < ActiveRecord::Migration
  def change
    add_column :users, :min_scheduled_shift_length, :integer, :default => 2
  end
end
