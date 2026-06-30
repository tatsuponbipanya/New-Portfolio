FactoryBot.define do
  factory :jog do
    # ジョギングデータを作る時は、自動で靴（Shoe）も作って紐づける。
    association :shoe

    distance { 42.195 }
    date { Date.current }
    time_hour { 0 }
    time_minute { 30 }
    time_second { 0 }
  end
end
