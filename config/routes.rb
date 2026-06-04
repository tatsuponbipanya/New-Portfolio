Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "home#index"
  post "workout_logs", to: "home#create", as: :workout_logs
  #asは、ビュー（HTML）側で workout_logs_path っていう**便利な近道用の名前（あだ名）**を使えるようにする設定。
  #複数のデータを扱う場合、必ず複数形（s）で設定する。でないとエラー。
  #このあだ名がないと、ビューのform_withの1行目を、「URLを直接手書き」して書かなきゃいけなくなる。
  #将来、URLを変更したくなったときも、ルーティングのファイルのURL部分を1箇所書き換えるだけで済む。
end
