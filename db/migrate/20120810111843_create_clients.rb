class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name, :null => false
      t.integer :standard_rate

      t.timestamps
    end
  end
end
