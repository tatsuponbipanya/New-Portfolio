Sentry.init do |config|
  # 本番環境の credentials から DSN を読み込む設定
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  
  # Railsのいつものログ（ActiveSupport::Logger）とも連携させる
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # エラーだけでなく、処理の重さを測るパフォーマンス監視の設定（0.0〜1.0で指定）
  # 本番環境（production）のときだけ10%の確率でデータを取る
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 0.0
end