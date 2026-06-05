require 'rails_helper'

RSpec.describe WorkoutLog, type: :model do
  it "全ての項目が入力されていれば有効であること" do
    workout_log = WorkoutLog.new(
      workout_date: Date.today,
      menu_type: "ベンチプレス",
      weight: 83.0,
      reps: 1
    )
    expect(workout_log).to be_valid
  end

  it "種目名が未入力の場合は無効であること" do
    workout_log = WorkoutLog.new(    
      workout_date: Date.today,
      menu_type: "", #未入力
      weight: 83.0,
      reps: 1
    )
    expect(workout_log).not_to be_valid
  end

end
