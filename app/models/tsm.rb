class Tsm < ApplicationRecord
	validates :name, presence: true
	has_many :sales_reps
end
