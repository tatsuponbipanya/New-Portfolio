class WorkoutTemplateSet < ApplicationRecord
  belongs_to :workout_template

  # 種目名・順番・重量・回数があるか
  validates :menu_type, presence: true
  validates :step_number, presence: true

  # 重量と回数が存在し、必ず「0以上の数字」であることを強制
  validates :default_weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :default_reps, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
