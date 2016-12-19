class CreateReportCriteria < ActiveRecord::Migration[5.0]
  def change
    create_table :report_criteria do |t|
    	t.string :criteria 
      t.timestamps
    end
  end
end
