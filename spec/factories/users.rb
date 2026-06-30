FactoryBot.define do
  factory :user do
    name { "たつマジロ" }
    sequence(:email) { |n| "test-#{n}@example.com" } # 被らないように自動で数字を増やす
    password { "12345678" }
  end
end