class WeekQuarterCount < ActiveRecord::Base
	validates :quarter, :week_count, presence: true, numericality: true
end