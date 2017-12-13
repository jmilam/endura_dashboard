class CreateWeekQuarterCount < ActiveRecord::Migration[5.0]
  def change
    create_table :week_quarter_counts do |t|
    	t.integer				:quarter
    	t.integer		 		:week_count

    	t.timestamps
    end
  end
end
