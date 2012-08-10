class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, :null => :false
      t.integer :hourly_rate
      t.integer :fee
      t.datetime :deadline_date
      t.datetime :date_finished

      t.timestamps
    end
  end
end
