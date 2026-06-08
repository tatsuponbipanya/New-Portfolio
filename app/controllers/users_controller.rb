class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # user_paramsは下で定義したメソッド。登録データがちゃんとあるか
    @user = User.new(user_params)
    if @user.save
      # 登録したら、そのまま自動ログイン
      session[:user_id] = @user.id
      redirect_to root_path, notice: "ユーザー登録が完了しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 編集が成功したら、そのユーザーのページ（show）に飛ばす
      redirect_to user_path(@user), notice: "プロフィールを編集しました。"
    else
      # 編集が失敗（バリデーションに引っかかる）したら、編集画面を再表示
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # admin: trueなどのハッキングデータを防ぐ。指定した項目のみ保存を許可
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :introduction)
  end
end
