source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.3'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# CSS用の最新のツール
gem 'tailwindcss-rails'

# 最強のパスワード暗号化（ハッシュ化）
gem 'bcrypt', '~> 3.1.7'

# スマホ通知を飛ばすためのVAPIDキー作成など
gem 'web-push'
# スマホ通知を定期的に飛ばすジェム
gem 'whenever', require: false

# 自動エラー検知機能
gem "sentry-ruby"
gem "sentry-rails"



# 開発・テスト用
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # 日本の自社開発企業のシェアNo.1テストツール
  gem 'rspec-rails'

  # 開発環境とテスト環境では SQLite を使う
  gem 'sqlite3', '>= 2.1'

  # テストコード自動整形RuboCopくん
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
end



# 本番環境（production）で PostgreSQL を使う
group :production do
  gem 'pg'
end
gem 'chartkick', '~> 5.2'
