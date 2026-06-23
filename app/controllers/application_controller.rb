class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # どの画面からでもhelper_methodを使えるようにする
  helper_method :current_user

  private

  # ログイン中のユーザーを特定するメソッド。
  def current_user
    # ||はメモ化。毎回データベースに問い合わせず@current_userを使い回せる。
    # Rubyは後置ifで書くのがワールドスタンダード。
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # ログインしていない人をログイン画面に飛ばす。
  def require_login
    return if current_user

    flash[:alert] = 'ログインが必要です。'
    redirect_to login_path
  end
end
