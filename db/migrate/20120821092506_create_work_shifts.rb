class CreateWorkShifts < ActiveRecord::Migration
  def change
    create_table :work_shifts do |t|
      t.datetime :start_time
      t.integer :duration
      t.integer :user_id

      t.timestamps
    end
  end
end
