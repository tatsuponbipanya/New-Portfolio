# cronに、rbenvのパスを教える
env :PATH, "/home/aiueo/.rbenv/shims:/home/aiueo/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"

# ログを出力する場所を指定
set :output, "log/cron_push.log"

# Railsの環境（開発環境ならdevelopment、本番ならproduction）
set :environment, "development"

# 毎日、夜の 17:00 に作ったコマンドを実行する
every 1.day, at: '17:00 pm' do
  rake "push_notification:send_daily"
end