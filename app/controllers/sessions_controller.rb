class SessionsController < ApplicationController
  def new; end

  def create
    # メールアドレスでユーザーを探す
    user = User.find_by(email: params[:email])

    # ユーザーが存在して、かつパスワードが正しいかチェック
    if user && user.authenticate(params[:password])
      # ログイン成功。セッションにユーザーIDを保存
      session[:user_id] = user.id
      redirect_to root_path, notice: 'ログインしました！'
    else
      # ログインに失敗した場合。nowをつけないと、次のページまでこのアラートが残る。
      flash.now[:alert] = 'メールかパスワードが正しくありません。'
      render :new
    end
  end

  def destroy
    # ログアウト処理。セッションを全て破棄。
    reset_session
    redirect_to root_path, notice: 'ログアウトしました。'
  end
end
