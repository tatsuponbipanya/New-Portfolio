class Api::CronTasksController < ApplicationController
  # APIなので画面のCSRFチェックはスキップ
  skip_before_action :verify_authenticity_token

  # rubocopエラー回避用
  # rubocop:disable Metrics/MethodLength
  def send_daily
    # GitHubから送られてくる合言葉が、Railsの秘密鍵と一致するかチェック
    if request.headers['Authorization'] == "Bearer #{ENV['CRON_TOKEN']}"

      # ランダムで送るメッセージの候補（配列の中にハッシュを入れる）
      daily_messages = [
        { title: 'グラノーラで食物繊維を摂ろう！', body: '1日あたり成人男性で21g以上、成人女性で18g以上の食物繊維が必要だよ！' },
        { title: '足の筋肉は圧倒的に落ちやすい！', body: '運動しないと、すぐ寝たきりになるよ！' },
        { title: '15分の運動で、8時間寿命が伸びるよ！', body: '32倍のタイムパフォーマンス！' },
        { title: 'ナッツを食べよう！', body: '毎日食べると心臓病による死亡リスクが29%、がんによる死亡リスクが11%も減少するよ！' },
        { title: 'ビタミンDを摂ろう！', body: '毎日2000IU摂取すると、がんによる死亡率が12%も減少するよ！' }
      ]

      # .sample でランダムに1つ選ぶ
      todays_message = daily_messages.sample

      subscriptions = NotificationSubscription.all

      subscriptions.find_each do |sub|
        WebPush.payload_send(
          # さっきランダムで選んだ todays_message を json にして送る
          message: todays_message.to_json,
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

      render json: { status: 'success', message: '全員にランダム通知を飛ばしたよ！' }, status: :ok
    else
      render json: { status: 'error', message: '合言葉が違います' }, status: :unauthorized
    end
  end
  # rubocopエラー回避用
  # rubocop:enable Metrics/MethodLength
end
