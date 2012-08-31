class CreateVacations < ActiveRecord::Migration
  def change
    create_table :vacations do |t|
      t.datetime :start_date, :null => false
      t.integer :user_id, :null => false
      t.datetime :end_date, :null => false

      t.timestamps
    end
  end
end
