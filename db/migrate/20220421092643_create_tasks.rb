class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.timestamps

      t.string :name, null: false
      t.integer :status, null: false
    end
  end
end
