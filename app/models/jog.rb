class Jog < ApplicationRecord
  belongs_to :shoe
  has_one :user, through: :shoe

  # 距離・日付・走行時間は入力必須にする
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :time_hour, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_minute, presence: true,
                          numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }
  validates :time_second, presence: true,
                          numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 }

  # ペースは自動計算。心拍数は未入力でも良いが、入力された場合は変な数字や文字でないかチェック
  validates :pace_minute, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pace_second, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :heart_rate, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }

  # 保存する前に自動でペースを計算するコールバックを設定
  before_save :calculate_pace

  # ジョグデータが新しくデータベースに保存された「直後」に、自動で走行距離を加算
  after_create :add_distance_to_shoe

  # ジョグデータが削除された「直後」に、走行距離の引き算を実行
  after_destroy :subtract_distance_from_shoe

  private

  # ペース自動計算メソッド
  def calculate_pace
    # 距離かタイムのいずれかが無ければ計算スキップ
    return unless distance.to_f > 0 && (time_hour.present? || time_minute.present? || time_second.present?)

    # 1. 全体の走行時間を「秒」にすべて変換
    total_seconds = (time_hour.to_i * 3600) + (time_minute.to_i * 60) + time_second.to_i

    # 2. 1kmあたりの秒数を出す（全体の秒数 ÷ 距離）
    pace_per_km = total_seconds / distance.to_f

    # 3. ペースの「分」と「秒」に分解して、モデルの属性に代入
    self.pace_minute = (pace_per_km / 60).to_i
    self.pace_second = (pace_per_km % 60).to_i
  end

  # 紐付いているシューズを引っ張ってきて、累計距離を加算して保存
  def add_distance_to_shoe
    new_total = shoe.total_distance.to_f + distance

    # update! ではなく update を使い、失敗したときの処理を自分で書く
    return if shoe.update(total_distance: new_total)

    # 1. シューズ側のエラーメッセージを、Jog（画面）側にコピーする
    errors.add(:base, "シューズの更新に失敗しました: #{shoe.errors.full_messages.join(', ')}")
    # 2. 強制的にエラーを発生させて、Jogの保存自体も確実にロールバックさせる
    raise ActiveRecord::RecordInvalid.new(self)
  end

  # 紐付いているシューズを引っ張ってきて、削除されたジョグの距離を減算して保存
  def subtract_distance_from_shoe
    new_total = shoe.total_distance.to_f - distance

    # 万が一マイナス値にならないように、[計算結果, 0.0] の大きい方を採用
    return if shoe.update(total_distance: [new_total, 0.0].max)

    errors.add(:base, "シューズの更新に失敗しました: #{shoe.errors.full_messages.join(', ')}")
    raise ActiveRecord::RecordInvalid.new(self)
  end
end
