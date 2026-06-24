class CheckoutsController < ApplicationController
  def create
    # Stripeの決済画面（セッション）を作成する
    session = Stripe::Checkout::Session.create({
                                                 payment_method_types: ['card'],

                                                 # ログイン中のユーザーIDをStripeに記憶させる
                                                 client_reference_id: current_user.id,

                                                 line_items: [{
                                                   price_data: {
                                                     currency: 'jpy', # 日本円
                                                     product_data: {
                                                       name: 'ポートフォリオV2 応援プラン' # 商品名
                                                     },
                                                     unit_amount: 500 # 値段（500円）
                                                   },
                                                   quantity: 1
                                                 }],
                                                 mode: 'payment', # まずは1回払いでテスト

                                                 # 決済成功・キャンセルしたときに戻ってくるURL
                                                 success_url: checkout_success_url,
                                                 cancel_url: root_url # キャンセルしたらトップページに戻る
                                               })

    # Stripeの決済画面へリダイレクト
    redirect_to session.url, allow_other_host: true
  end

  def success
    # 決済成功後に表示する画面のアクション
  end
end
