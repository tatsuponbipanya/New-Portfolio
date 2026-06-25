require 'rails_helper'

RSpec.describe 'Stripe Webhooks', type: :request do
  it '決済完了通知が来たら、ユーザーがプレミアム会員になること' do
    # 1. テスト用のユーザーを作る
    user = User.create!(
      name: 'たつマジロ',
      email: 'tatsu@example.com',
      password: 'password', # password_digestをパスするため
      premium: false
    )

    # 2. 署名検証を突破する裏技（モック）
    # WebhooksControllerは client_reference_id を見ているので、
    # さっき作ったユーザーのID（user.id）をそこにセット
    dummy_event = Stripe::Event.construct_from({
                                                 type: 'checkout.session.completed',
                                                 data: {
                                                   object: {
                                                     client_reference_id: user.id # ←ここが超重要！
                                                   }
                                                 }
                                               })
    allow(Stripe::Webhook).to receive(:construct_event).and_return(dummy_event)

    # 3. RailsのWebhookのURL（エンドポイント）に通信を送る
    post '/webhooks', params: {}.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }

    # 4. ユーザーのデータが更新されたかチェックする
    user.reload
    expect(user.premium).to eq(true)
  end
end
