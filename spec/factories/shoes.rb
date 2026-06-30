FactoryBot.define do
  factory :shoe do
    # 靴を作る時は、自動で新しい持ち主（User）も1人作って紐づける。
    association :user

    name { 'ハイヒール' }
    target_distance { 500.0 }
    size { 29.0 }
    width { '2E' }
    bought_on { Date.today }
    total_distance { 0.0 }
  end
end
