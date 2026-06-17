class UsersController < ApplicationController
before_action :ensure_correct_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def create
    # user_paramsは下で定義したメソッド。入力データがちゃんとあるかチェックしてから、ユーザー作成。
    @user = User.new(user_params)
    if @user.save
      # 登録したら、そのまま自動ログイン
      session[:user_id] = @user.id
      redirect_to root_path, notice: "ユーザー登録が完了しました。"
    else
      # データを保存する画面の失敗には、422（unprocessable_entity）を添える。これがないと、中身がエラーなのに通信は成功することで、Turboなどが正常だと勘違いし、バグる原因になる。
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    @workout_logs = @user.workout_logs.order(workout_date: :desc)

    # グラフ用（トレーニング比率の方）。過去の記録をgroup_byで部位ごとに分け、mapで配列を作り直す（{部位・ボリュームの合計}　の形へ）。グラフ用のデータは、to_hでハッシュ化する必要がある。
    @chart_data = @workout_logs.group_by(&:body_part).map do |part, logs|
      [part, logs.sum { |log| log.weight * log.reps }]
    end.to_h
  end

  # before_actionのensure_correct_userで@userを見つけているため、editには何も書かなくて良い。
  def edit
  end

  def update
    if @user.update(user_params)
      # 編集が成功したら、そのユーザーのページ（show）に飛ばす
      redirect_to user_path(@user), notice: "プロフィールを編集しました。"
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

    if @user != current_user
      flash[:alert] = "他のユーザーのプロフィールは編集できません。"
      redirect_to root_path
    end
  end
end
