class Api::CronTasksController < ApplicationController
  # APIなので画面のCSRFチェックはスキップ
  skip_before_action :verify_authenticity_token

  def send_daily
    # GitHubから送られてくる合言葉が、Railsの秘密鍵と一致するかチェック
    if request.headers['Authorization'] == "Bearer #{ENV['CRON_TOKEN']}"

      # 通知送信のロジック
      subscriptions = NotificationSubscription.all

      subscriptions.find_each do |sub|
        WebPush.payload_send(
          message: { title: '今日の配信のお知らせ！', body: '今日も1日お疲れ様！' }.to_json,
          endpoint: sub.endpoint,
          p256dh: sub.p256dh,
          auth: sub.auth,
          vapid: {
            public_key: Rails.application.credentials.dig(:vapid, :public_key),
            private_key: Rails.application.credentials.dig(:vapid, :private_key),
            expiration: 24 * 60 * 60
          }
        )
      rescue StandardError => e
        sub.destroy if e.message.include?('410') || e.message.include?('Gone')
      end

      render json: { status: 'success', message: '全員に通知を飛ばしたよ！' }, status: :ok
    else
      render json: { status: 'error', message: '合言葉が違います' }, status: :unauthorized
    end
  end
end
