class WorkoutLog < ApplicationRecord
    validates :menu_type, presence: true
    #数字で（ニューメリキャリティ）、0より大きい場合のみ許可
    validates :weight, numericality: { greater_than: 0 }
    #数字で（ニューメリキャリティ）、整数（integer）の、0より大きい場合のみ許可
    validates :reps, numericality: { only_integer: true, greater_than: 0 }
end
