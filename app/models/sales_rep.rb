class SalesRep < ApplicationRecord
  validates :name, presence: true
  validates :personnel_count, presence: true, numericality: true
  validates :tsm_id, presence: true, numericality: true
  belongs_to :tsm

end
