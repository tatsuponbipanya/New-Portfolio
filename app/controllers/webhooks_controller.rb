class WebhooksController < ApplicationController
  # Stripeからの通信にはCSRFトークンがないので、セキュリティチェックをスキップする
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    # Webhook用の秘密鍵
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET'] || Rails.application.credentials.dig(:stripe, :webhook_secret)

    event = nil

    begin
      # 届いた通知が「本当にStripeから来たものか（偽物じゃないか）」を鍵を使って検証する
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # データが壊れていた場合
      render status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # 偽物からのアクセスだった場合
      render status: 400
      return
    end

    # Stripeから送られてきたイベントの種類で処理を分ける
    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      
      # Stripeから記憶させたユーザーIDを回収
      user_id = session.client_reference_id
      
      # データベースからそのユーザーを探し出して、プレミアムにする
      user = User.find_by(id: user_id)
      
      if user
        user.update!(premium: true)
        
        puts "===================================="
        puts "【大成功】#{user.name}さんがプレミアム会員になりました！"
        puts "===================================="
      else
        puts "ユーザーが見つかりませんでした (User ID: #{user_id})"
      end
    end

    # 最後にStripeへ「無事に受け取ったよ！」と200 OKを返す（これがないとStripeが何度も再送してくる）
    render json: { message: 'success' }, status: 200
  end
end