class HomeController < ApplicationController
  # ログインしていなかったら、ログイン画面へリダイレクト
  before_action :require_login
  # ただし、トップページのみは表示可能
  skip_before_action :require_login, only: [:index]

  def index
    if current_user
      # 1セット用のインスタンスではなく、WorkoutFormの空の箱を用意する
      @workout_form = WorkoutForm.new(workout_date: Time.current)
      # その人の記録だけ表示
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
    else
      # ログインしてない場合は、トップページへ
      render :landing
    end
  end

  def create
    # 送られてきた3セット分のデータを、Formオブジェクトに丸ごと渡す
    # workout_form_paramsは、privateで設定したセキュリティチェックの済んだデータ。
    @workout_form = WorkoutForm.new(workout_form_params)
    
    # ログイン中のユーザーIDをフォームオブジェクトにセットする
    @workout_form.user_id = current_user.id

    if @workout_form.save
      redirect_to user_path(current_user), notice: "筋トレが記録されました。"
    else
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
      render :index, status: :unprocessable_entity
      # status: :unprocessable_entityで422 (リクエストは届いたけど、データがダメで処理できない）を明示しないと、
      # Hotwire（Turbo）が正常にエラー画面をレンダリングしてくれずバグの原因になる
    end
  end

  def destroy
    @workout_log = current_user.workout_logs.find(params[:id])
      @workout_log.destroy
      redirect_to user_path(current_user), notice: "筋トレ記録を削除しました。"
  end

  # 種目別グラフ用（推定1RM推移）
  def analytics
    @user = User.find(params[:id])
    # 日付の古い順にデータを並び替え（orderはデフォでASC（昇順）になる）
    @workout_logs = @user.workout_logs.order(:workout_date)
    # 種目名を重複なしで取得（pluckでログから種目名のみ抜き出し、uniqで重複を除く）
    @menu_types = @workout_logs.pluck(:menu_type).uniq

    # 種目ごとにグループ化し、｛日付 => その日の最高推定MAX重量(1RM)｝のハッシュを作る。
    # まずgroup_byで種目ごとにデータを分け、transform_valuesで種目名（キー）は固定したまま、中身のデータを総入れ替えする。
    @chart_data_by_menu = @workout_logs.group_by(&:menu_type).transform_values do |logs|
      # さらに「日付（workout_date）」ごとにデータをグループ化（同日の複数セットをまとめる）
      # ここでもtransform_valuesを使い、日付（キー）は固定のまま、中身を「その日の1RM最大値」に書き換える。
      logs.group_by { |log| log.workout_date.to_date }.transform_values do |daily_logs|
        # 同日のすべてのセット（daily_logs）から、それぞれの推定1RMを計算する
        daily_logs.map(&:estimated_1rm).max
      end
    end
  end

  private
  #カプセル化（隠蔽）。外からURL（インターネット）経由で呼び出せないメソッド。
  #ハッカーがURLの入力を工夫して、以下のメソッドを直接狙い撃ちしてきても無効に出来る。

  #セキュリティ。ちゃんとworkout_formのデータがあるかのチェックと、日付、メニュー名、重量、回数の4つのデータだけを通過許可。
  #これがないと、admin: true（自分を管理者権限にする）などのデータが通ってしまう。
  def workout_form_params
    params.require(:workout_form).permit(
      :workout_date,
      :menu_type,
      sets_attributes: [:weight, :reps] # 各セットの重量と回数の塊を許可
    )
  end
end