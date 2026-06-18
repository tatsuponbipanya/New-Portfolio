Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 筋トレのデータ記録（トップページは home のままでOK）
  root 'home#index'
  get 'users/:id/analytics', to: 'home#analytics', as: :analytics
  get 'users/:id/workout_logs', to: 'home#workout_logs', as: :user_workout_logs
  post 'workout_logs', to: 'home#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'home#destroy', as: :workout_log

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
    resources :jogs, only: [:index]
    resources :shoes, only: [:index]
  end
    resources :shoes, only: [:new, :create, :destroy]
    resources :jogs, only: [:new, :create, :destroy]
end