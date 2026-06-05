Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ユーザー登録
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  # ログイン・ログアウト
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 筋トレのデータ記録
  root "home#index"
  post "workout_logs", to: "home#create", as: :workout_logs
  #asは、ビュー（HTML）側で workout_logs_path っていう**便利な近道用の名前（あだ名）**を使えるようにする設定。
  #複数のデータを扱う場合、必ず複数形（s）で設定する。でないとエラー。
  #このあだ名がないと、ビューのform_withの1行目を、「URLを直接手書き」して書かなきゃいけなくなる。
  #将来、URLを変更したくなったときも、ルーティングのファイルのURL部分を1箇所書き換えるだけで済む。
end
