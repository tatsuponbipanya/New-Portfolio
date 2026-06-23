class NotificationSubscriptionsController < ApplicationController
  def create
    # ログインしているユーザーに紐付けて保存する
    subscription = current_user.notification_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])

    # 住所と暗号鍵をデータベースに保存する
    subscription.update!(
      p256dh: params.dig(:keys, :p256dh),
      auth: params.dig(:keys, :auth)
    )

    head :ok # 無事に受け取ったよという合図だけ返す
  end
end
