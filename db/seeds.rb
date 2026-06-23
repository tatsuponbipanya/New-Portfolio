# テスト用のデータを予めここで作っておく。

# 紐づけるユーザー（登録されている最初のユーザーか、いなければ作成）を取得
user = User.first || User.create!(email: 'tatsuponbipanya@gmail.com', password: 'unko', name: 'たつマジロ')

if user
  # 1. たつマジロの「月曜：胸の日」テンプレートを作成
  chest_template = user.workout_templates.create!(name: '月曜：胸の日（ベンチメイン）')

  # 2. そのテンプレートに紐づくセット内容を登録
  WorkoutTemplateSet.create!([
                               { workout_template: chest_template, menu_type: 'ベンチプレス', step_number: 1,
                                 default_weight: 55.5, default_reps: 6 },
                               { workout_template: chest_template, menu_type: 'ベンチプレス', step_number: 2,
                                 default_weight: 60.5, default_reps: 5 },
                               { workout_template: chest_template, menu_type: 'ベンチプレス', step_number: 3,
                                 default_weight: 65.5, default_reps: 4 }
                             ])

  # 3. もう一個「土曜：下半身の日」も作る
  leg_template = user.workout_templates.create!(name: '土曜：デッドリフト')

  WorkoutTemplateSet.create!([
                               { workout_template: leg_template, menu_type: 'デッドリフト', step_number: 1,
                                 default_weight: 74.6, default_reps: 5 },
                               { workout_template: leg_template, menu_type: 'デッドリフト', step_number: 2,
                                 default_weight: 120.6, default_reps: 5 }
                             ])

  puts 'テンプレートのテストデータを作ったよ！'
else
  puts 'ユーザーが一人もいません！'
end
