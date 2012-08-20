class CreateCompletedShifts < ActiveRecord::Migration
  def change
    create_table :completed_shifts do |t|
      t.datetime :start_date, :null => false
      t.integer :duration, :null => false
      t.integer :task_id, :null => false

      t.timestamps
    end
  end
end
