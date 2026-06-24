# config/initializers/stripe.rb

Rails.configuration.stripe = {
  # ENV（環境変数）に設定されていればそれを使い、なければRailsのcredentialsから探す
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'] || Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
}

# Stripe本体にシークレットキーを覚えさせる
Stripe.api_key = Rails.configuration.stripe[:secret_key]
