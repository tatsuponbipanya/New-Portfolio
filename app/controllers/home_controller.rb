class HomeController < ApplicationController
  # ログインしていなかったら、ログイン画面へリダイレクト
  before_action :require_login
  # ただし、トップページのみは表示可能
  skip_before_action :require_login, only: [:index]

  def index
    if current_user
      # 新しく記録するための空のインスタンス作成（入力フォームの準備に必要）
      @workout_log = WorkoutLog.new
      # その人の記録だけ表示
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
    else
      # ログインしてない場合は、トップページへ
      render :landing
    end
  end

  def create
    # 入力されたデータを入れてインスタンス作成
    @workout_log = current_user.workout_logs.build(workout_log_params)
    #workout_log_paramsは、privateで設定したセキュリティチェックの済んだデータ。

    if @workout_log.save
      redirect_to user_path(current_user), notice: "筋肉が記録されました。"
    else
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
      render :index, status: :unprocessable_entity
      #status: :unprocessable_entityで422 (リクエストは届いたけど、データがダメで処理できない）を明示しないと、
      #Hotwire（Turbo）が正常にエラー画面をレンダリングしてくれずバグの原因になる
    end
  end

  def destroy
    @workout_log = current_user.workout_logs.find(params[:id])
      @workout_log.destroy
      redirect_to user_path(current_user), notice: "筋トレ記録を削除しました。"
  end

  private
  #カプセル化（隠蔽）。外からURL（インターネット）経由で呼び出せないメソッド。
  #ハッカーがURLの入力を工夫して、以下のメソッドを直接狙い撃ちしてきても無効に出来る。

  def workout_log_params
    params.require(:workout_log).permit(:workout_date, :menu_type, :weight, :reps)
    #セキュリティ。ちゃんとworkout_logのデータがあるかのチェックと、日付、メニュー名、重量、回数の4つのデータだけを通過許可。
    #これがないと、admin: true（自分を管理者権限にする）などのデータが通ってしまう。
  end
end