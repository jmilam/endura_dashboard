class CreateResponsibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :responsibilities do |t|
    	t.string :name

      t.timestamps
    end
  end
end
