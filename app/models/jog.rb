class Jog < ApplicationRecord
  belongs_to :shoe

  validates :distance, presence: true, numericality: { greater_than: 0 }

  # ジョグデータが新しくデータベースに保存された「直後」に、自動で計算を実行
  after_create :add_distance_to_shoe

  private

  def add_distance_to_shoe
    # 紐付いているシューズを引っ張ってきて、累計距離を加算して保存
    new_total = shoe.total_distance.to_f + distance
    shoe.update!(total_distance: new_total)
  end
end