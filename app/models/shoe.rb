class Shoe < ApplicationRecord
  belongs_to :user

  has_many :jogs, dependent: :destroy

  validates :name, presence: true
  validates :target_distance, presence: true, numericality: { greater_than: 0 }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :width, presence: true
  validates :bought_on, presence: true

  # 未来の日付は登録させない
  validate :bought_on_cannot_be_in_the_future

  private

  # 未来の日付は登録させない
  def bought_on_cannot_be_in_the_future
    return unless bought_on.present? && bought_on > Date.today

    errors.add(:bought_on, 'は未来の日付を選択できません')
  end
end
