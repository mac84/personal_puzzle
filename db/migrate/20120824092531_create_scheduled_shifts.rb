class CreateScheduledShifts < ActiveRecord::Migration
  def change
    create_table :scheduled_shifts do |t|
      t.integer :task_id, :null => false
      t.datetime :start_date, :null => false
      t.integer :duration, :null => false

      t.timestamps
    end
  end
end
