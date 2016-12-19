class CreateFailureCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :failure_codes do |t|
    	t.integer :responsibility_id
    	t.string :name
      t.timestamps
    end
  end
end
