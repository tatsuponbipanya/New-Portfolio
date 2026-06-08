class WorkoutLog < ApplicationRecord
    #記録は必ず一人のユーザーに属している
    belongs_to :user

    validates :menu_type, presence: true
    #数字で（ニューメリキャリティ）、0以上の場合のみ許可
    validates :weight, numericality: { greater_than_or_equal_to: 0 }
    #数字で（ニューメリキャリティ）、整数（integer）の、0より大きい場合のみ許可
    validates :reps, numericality: { only_integer: true, greater_than: 0 }

    # グラフの判定ロジック
    def body_part
      case menu_type
      when /ベンチプレス|ダンベルプレス|チェストプレス/
        "胸"
      when /スクワット|レッグプレス|ランジ/
        "脚"
      when /デッドリフト|チンニング|ラットプルダウン/
        "背中"
      when /ショルダープレス|サイドレイズ/
        "肩"
      when /アームカール|ディップス/
        "腕"
      else
        "その他"
      end
    end
end
