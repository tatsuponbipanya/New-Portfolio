# app/controllers/home_controller.rb
class HomeController < ApplicationController
  # ログインしていなかったら、ログイン画面へリダイレクト
  before_action :require_login

  # ただし、landingページのみは表示出来る
  skip_before_action :require_login, only: [:index]

  def index
    unless current_user
      # ログインしてない場合は、トップページへ
      render :landing
    end
  end

end