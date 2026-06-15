Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ユーザー登録
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  # ユーザー一覧ページ
  # 必ず（users/:id）より上に書く！
  get 'users', to: 'users#index'

  # プロフィール編集・更新
  get 'users/:id/edit', to: 'users#edit', as: :edit_user
  patch 'users/:id', to: 'users#update', as: :user
  # 更新・上書きする場合はpatchを使うのがルール。
  get 'users/:id', to: 'users#show'

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 筋トレのデータ記録・削除・分析
  root 'home#index'
  get 'users/:id/analytics', to: 'home#analytics', as: :analytics
  post 'workout_logs', to: 'home#create', as: :workout_logs
  delete 'workout_logs/:id', to: 'home#destroy', as: :workout_log
  # asは、ビュー（HTML）側で workout_logs_path っていう**便利な近道用の名前（あだ名）**を使えるようにする設定。
  # 複数のデータを扱う場合、必ず複数形（s）で設定する。でないとエラー。
  # このあだ名がないと、ビューのform_withの1行目を、「URLを直接手書き」して書かなきゃいけなくなる。
  # 将来、URLを変更したくなったときも、ルーティングのファイルのURL部分を1箇所書き換えるだけで済む。

  # テンプレートの作成画面、保存・編集
  get 'workout_templates/new', to: 'home#new_template', as: :new_workout_template
  post 'workout_templates', to: 'home#create_template', as: :workout_templates
  get 'workout_templates', to: 'home#new_template'
  delete 'workout_templates/:id', to: 'home#destroy_template', as: :destroy_workout_template
  get 'workout_templates/manage', to: 'home#index_templates', as: :manage_workout_templates
end
