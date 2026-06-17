Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ユーザー管理（signup や login は手動のままで）
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'
  resources :users, only: [:index, :show, :edit, :update]

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 筋トレのデータ記録（トップページは home のままでOK）
  root 'home#index'
  get 'users/:id/analytics', to: 'home#analytics', as: :analytics
  post 'workout_logs', to: 'home#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'home#destroy', as: :workout_log

  # テンプレート管理
  resources :workout_templates, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      # 「編集・削除」ボタンの遷移先（manage_workout_templates_path）のあだ名を残すための設定
      get :manage, action: :index 
    end
  end
end