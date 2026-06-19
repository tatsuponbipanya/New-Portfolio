# app/controllers/home_controller.rb
class HomeController < ApplicationController
  # ログインしていなかったら、ログイン画面へリダイレクト
  before_action :require_login
  # ただし、トップページのみは表示可能
  skip_before_action :require_login, only: [:index]



  # カプセル化（隠蔽）。外からURL（インターネット）経由で呼び出せないメソッド。
  private

  # セキュリティ。ちゃんとworkout_formのデータがあるかのチェックと、日付、メニュー名、重量、回数の4つのデータだけを通過許可。
  def workout_form_params
    params.require(:workout_form).permit(
      :workout_date,
      :menu_type,
      sets_attributes: [:weight, :reps]
    )
  end
end