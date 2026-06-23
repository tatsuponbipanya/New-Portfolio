namespace :push_notification do
  desc "毎日1回の定期プッシュ通知を送信する"
  task send_daily: :environment do
  # 日替わりメッセージ（ここを好きなだけ増やす）
  messages_pool = [
    { title: "定期便", body: "15分の運動で8時間寿命が伸びるよ！" },
    { title: "定期便", body: "グラノーラで食物繊維を摂ろう！食物繊維は1日あたり女性で18g、男性で21g必要だよ！" },
    { title: "定期便", body: "1年以上筋トレを続けられるのはわずか4%！継続が大事だよ！" },
  ]

  # 今日のメッセージをランダムで1つ決定
  today_message = messages_pool.sample

  subscriptions = NotificationSubscription.all
  next if subscriptions.empty?

  subscriptions.find_each do |sub|
    begin
      WebPush.payload_send(
        message: today_message.to_json,
        endpoint: sub.endpoint,
        p256dh: sub.p256dh,
        auth: sub.auth,
          vapid: {
            public_key: Rails.application.credentials.dig(:vapid, :public_key),
            private_key: Rails.application.credentials.dig(:vapid, :private_key),
            expiration: 24 * 60 * 60
          }
        )
        puts "ID: #{sub.id} の端末に通知を送った！"

      rescue => e
        puts "ID: #{sub.id} でエラーが出ました#{e.message}"
        
        # もし有効期限切れ（410 Gone）だったら、自動でDBから削除
        if e.message.include?("410") || e.message.include?("Gone")
          sub.destroy
          puts "有効期限切れのため、ID: #{sub.id} のデータをDBから削除しました"
        end
      end
    end

    puts "--- すべての送信処理が終わった！大成功！ ---"
  end
end