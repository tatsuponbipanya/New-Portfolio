class Shoe < ApplicationRecord
  has_many :jogs, dependent: :destroy

  validates :name, presence: true
  validates :target_distance, presence: true, numericality: { greater_than: 0 }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :width, presence: true
end
