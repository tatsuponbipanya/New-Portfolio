class WorkoutTemplate < ApplicationRecord
  belongs_to :user
  has_many :workout_template_sets, dependent: :destroy

  # 親と一緒に子のレコードも同時に保存・変更できるようにする
  accepts_nested_attributes_for :workout_template_sets, allow_destroy: true

  validates :name, presence: true
end
