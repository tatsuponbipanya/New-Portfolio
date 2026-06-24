class UsersController < ApplicationController
  before_action :ensure_correct_user, only: %i[edit update]

  def new
    @user = User.new
  end

  def index
    # IDが小さい順＝登録した順に並び替える
    @users = User.order(id: :asc)
  end

  def create
    # user_paramsは下で定義したメソッド。入力データがちゃんとあるかチェックしてから、ユーザー作成。
    @user = User.new(user_params)
    if @user.save
      # 登録したら、そのまま自動ログイン
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'ユーザー登録が完了しました。'
    else
      # データを保存する画面の失敗には、422（unprocessable_entity）を添える。これがないと、中身がエラーなのに通信は成功することで、Turboなどが正常だと勘違いし、バグる原因になる。
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  # before_actionのensure_correct_userで@userを見つけているため、editには何も書かなくて良い。
  def edit; end

  def update
    if @user.update(user_params)
      # 編集が成功したら、そのユーザーのページ（show）に飛ばす
      redirect_to user_path(@user), notice: 'プロフィールを編集しました。'
    else
      # 編集が失敗（バリデーションに引っかかる）したら、編集画面を再表示。データを保存する画面の失敗には、422（unprocessable_entity）を添える。
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # admin: trueなどのハッキングデータを防ぐ。ユーザーの情報が含まれているか確認し、指定した項目のみ保存を許可。
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :introduction)
  end

  # 編集や更新を行うユーザーが、本人かどうか確認する。
  def ensure_correct_user
    @user = User.find(params[:id])

    return unless @user != current_user

    flash[:alert] = '他のユーザーのプロフィールは編集できません。'
    redirect_to root_path
  end
end
