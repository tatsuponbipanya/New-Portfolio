Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # トップページ
  root 'home#index'

  # スマホ通知用
  post '/notification_subscriptions', to: 'notification_subscriptions#create'

  # スマホ通知用（Github Actions）
  namespace :api do
    post 'cron_tasks/send_daily', to: 'cron_tasks#send_daily'
  end

  # 筋トレ関連
  # 筋トレ開始
  get 'users/:id/workout_logs/new', to: 'workout_logs#index', as: :user_workout_logs
  # 過去の記録
  get 'users/:id/workout_logs', to: 'workout_logs#workout_logs', as: :user_workout_logs_page
  # 記録の保存と削除
  post 'workout_logs', to: 'workout_logs#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'workout_logs#destroy', as: :workout_log

  # 分析（analytics）ページ
  get 'users/:id/analytics', to: 'workout_logs#analytics', as: :analytics

  # テンプレート管理
  resources :workout_templates, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      # 「編集・削除」ボタンの遷移先（manage_workout_templates_path）のあだ名を残すための設定
      get :manage, action: :index 
    end
  end

  # ユーザー管理（signup や login は手動のままで）
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  # シューズ管理とジョギング記録
  resources :users, only: [:index, :show, :edit, :update] do
    # shoesは index だけをユーザーに紐づける（これがマイシューズページ）
    resources :shoes, only: [:index]
    resources :jogs, only: [:index, :new, :create, :edit, :update, :destroy] do
      # 年間記録はデータ全体を扱うページなので、URLにIDは不要。collection doでIDを消す（IDが必要なのは、特定の1件のデータを扱うページのみ）。
      collection do
        get :annual
      end
    end
  end

  # newやcreate、destroyは外側で管理
  resources :shoes, only: [:new, :create, :edit, :update, :destroy]
end