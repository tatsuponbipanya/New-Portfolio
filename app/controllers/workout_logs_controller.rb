class WorkoutLogsController < ApplicationController

  def index
    if current_user
      # 1セット用のインスタンスではなく、WorkoutFormの空の箱を用意する
      @workout_form = WorkoutForm.new(workout_date: Time.current)
      # その人の記録だけ表示
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
      # ログインしているユーザーのテンプレート一覧を取得して画面に送る
      @templates = current_user.workout_templates.includes(:workout_template_sets)
    else
      # ログインしてない場合は、トップページへ
      render :landing
    end
  end

  def create
    # 送られてきた3セット分のデータを、Formオブジェクトに丸ごと渡す
    @workout_form = WorkoutForm.new(workout_form_params)
    
    # ログイン中のユーザーIDをフォームオブジェクトにセットする
    @workout_form.user_id = current_user.id

    if @workout_form.save
      redirect_to user_path(current_user), notice: "筋トレが記録されました！"
    else
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
      @templates = current_user.workout_templates
      render :index, status: :unprocessable_entity
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

    # 種目ごとにグループ化し、｛日付 => その日の最高推定MAX重量(1RM)｝のハッシュを作る。グラフ用のデータはハッシュでないといけない。
    @chart_data_by_menu = @workout_logs.group_by(&:menu_type).transform_values do |logs|
      # 「日付（workout_date）」ごとにデータをグループ化（同日の複数セットをまとめる）
      logs.group_by { |log| log.workout_date.to_date }.transform_values do |daily_logs|
        # 同日のすべてのセット（daily_logs）から、それぞれの推定1RMを計算して再配列化し、最大値を取得。
        daily_logs.map(&:estimated_1rm).max
      end
    end
  end

  # 筋トレ記録＋円グラフ
  def workout_logs
    @user = User.find(params[:id])
    # ユーザーの過去の筋トレ記録を、日付の新しい順に取得
    @workout_logs = @user.workout_logs.order(workout_date: :desc, id: :desc)

    # 筋トレ比率（円グラフ用）のデータを部位ごとに集計してハッシュ化
    @chart_data = @workout_logs.group_by(&:body_part).map do |part, logs|
      [part, logs.sum { |log| log.weight * log.reps }]
    end.to_h
  end
end
