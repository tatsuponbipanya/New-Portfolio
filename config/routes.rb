Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # トップページ
  root 'home#index'

  # 筋トレ関連
  # 分析（analytics）ページ
  get 'users/:id/analytics', to: 'workout_logs#analytics', as: :analytics 

  # 今から筋トレを記録し始めるページへのルート
  get 'users/:id/workout_logs/new', to: 'workout_logs#index', as: :user_workout_logs

  # ユーザーに紐づく筋トレ実績一覧
  get 'users/:id/workout_logs', to: 'workout_logs#workout_logs', as: :user_workout_logs_page
  
  # 記録の保存と削除
  post 'workout_logs', to: 'workout_logs#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'workout_logs#destroy', as: :workout_log

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
    resources :jogs, only: [:index, :new, :create, :edit, :update, :destroy]
  end

  # newやcreate、destroyは外側で管理
  resources :shoes, only: [:new, :create, :edit, :update, :destroy]
  end