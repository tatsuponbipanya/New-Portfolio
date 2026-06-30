FactoryBot.define do
  factory :workout_log do
      # ユーザーと紐づける
      association :user

      workout_date { Date.today }
      menu_type { 'ベンチプレス' }
      weight { 83.0 }
      reps { 1 }
  end
end