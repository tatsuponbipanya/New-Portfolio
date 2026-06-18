class Jog < ApplicationRecord
  belongs_to :shoe
  has_one :user, through: :shoe

  # 距離・日付・走行時間は入力必須にする
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :time_hour, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_minute, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }
  validates :time_second, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }

  # ペース・心拍数は未入力でも良いが、入力された場合は変な数字や文字でないかチェック
  validates :pace_minute, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }
  validates :pace_second, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }
  validates :heart_rate, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }

  # ジョグデータが新しくデータベースに保存された「直後」に、自動で計算を実行
  after_create :add_distance_to_shoe

  private

  def add_distance_to_shoe
    # 紐付いているシューズを引っ張ってきて、累計距離を加算して保存
    new_total = shoe.total_distance.to_f + distance
    shoe.update!(total_distance: new_total)
  end
end