class CreateSalesReps < ActiveRecord::Migration[5.0]
  def change
    create_table :sales_reps do |t|
      t.references :tsm#, foreign_key: true
      t.string :name
      t.integer :personnel_count

      t.timestamps
    end
  end
end
