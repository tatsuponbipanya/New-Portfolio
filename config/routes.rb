Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # トップページ
  root 'home#index'

  # スマホ通知用（コントローラー）
  post '/notification_subscriptions', to: 'notification_subscriptions#create'

  # スマホ通知用（Github Actions） 外部APIのルートはnamespaceで隔離してわかりやすくしておく。
  namespace :api do
    post 'cron_tasks/send_daily', to: 'cron_tasks#send_daily'
  end

  # クレジット決済用（Stripe・Webhook）
  # ユーザーがプレミアム登録ボタンを押したときに、Stripeの決済ページヘ遷移
  resources :checkouts, only: [:create]
  # ユーザーが、決済が完了した時に成功画面を表示
  get 'checkout/success', to: 'checkouts#success'
  # Stripeのシステムが、決済が完了した時にサーバーから非同期で通知を受け取る
  post '/webhooks', to: 'webhooks#create'

  # 筋トレ関連
  # 筋トレ開始（URLにusers/:idを入れたかったり、コントローラー名をresourcesの標準ルールを違うものを設定しているため、手動で記述）
  get 'users/:id/workout_logs/new', to: 'workout_logs#index', as: :user_workout_logs
  # 過去の記録
  get 'users/:id/workout_logs', to: 'workout_logs#workout_logs', as: :user_workout_logs_page
  # 記録の保存と削除
  post 'workout_logs', to: 'workout_logs#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'workout_logs#destroy', as: :workout_log
  # 分析（analytics）ページ
  get 'users/:id/analytics', to: 'workout_logs#analytics', as: :analytics
  # テンプレート管理
  resources :workout_templates, only: %i[index new create edit update destroy] do
    # collection doでURLのIDを消す。
    collection do
      # 「編集・削除」ボタンの遷移先（manage_workout_templates_path）のあだ名を残すための設定。
      # URLの後ろにmanageを追加し、workout_templatesコントローラーのindexアクションに飛ばす。
      # Formやコントローラーのリファクタリングをした際に、ビュー側の名前を全部直すが大変だったため元のあだ名をそのまま使用。
      get :manage, action: :index
    end
  end

  # ユーザー管理（signup や login というURLを使いたいので手動（get・post）で記述。）
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  # シューズ管理とジョギング記録
  resources :users, only: %i[index show edit update] do
    # shoesは index だけをユーザーに紐づける（これがマイシューズページ）
    # 一覧画面は、誰のシューズ一覧なのか分からないといけないから、ネストの中に入れてURLに:user_idが含まれる形にする。
    # %iを使うことで複数の内容をカンマ無しで書けるが、内容が1個の場合はカンマ1つもいらないので本来の書き方の方が見やすい。
    resources :shoes, only: [:index]
    resources :jogs, only: %i[index new create edit update destroy] do
      # 年間記録はデータ全体を扱うページなので、URLにIDは不要。よってcollection doでIDを消す（IDが必要なのは、特定の1件のデータを扱うページのみ）。
      collection do
        get :annual
      end
    end
  end

  # newやcreate、destroyは外側で管理。
  # シューズのデータ自体にuser_idがすでに紐付いているから、ネストの中に入れてURLにわざわざ:user_idを含めなくても、/shoes/5（5番のシューズを削除）だけで良い。
  resources :shoes, only: %i[new create edit update destroy]
end
