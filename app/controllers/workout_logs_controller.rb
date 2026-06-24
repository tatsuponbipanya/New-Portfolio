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
      redirect_to user_workout_logs_page_path(current_user), notice: '筋トレが記録されました！'
    else
      @workout_logs = current_user.workout_logs.order(workout_date: :desc)
      @templates = current_user.workout_templates
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    # 1. まず、クリックされた特定の1セットの記録を取得する
    target_log = current_user.workout_logs.find(params[:id])
    # 2. その記録と同じ「日付（秒まで一致）」かつ「種目名」のデータをすべて集める
    @workout_logs = current_user.workout_logs.where(
      workout_date: target_log.workout_date,
      menu_type: target_log.menu_type
    )
    # 3. 集まったセットをまとめて全部削除
    @workout_logs.destroy_all
    redirect_to user_workout_logs_page_path(current_user), notice: '筋トレ記録を削除しました。'
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

    # 種目ごとの「過去最高1RM」を取得してハッシュに入れる
    @max_1rm_by_menu = @chart_data_by_menu.transform_values do |daily_max_hash|
      daily_max_hash.values.max || 0.0 # 日付ごとのMAXの中から、最大値をゲット
    end
  end

  # 筋トレ記録＋円グラフ
  def workout_logs
    @user = User.find(params[:id])
    # ユーザーの過去の筋トレ記録を、日付の新しい順に取得
    @workout_logs = @user.workout_logs.order(workout_date: :desc, id: :desc)

    # 筋トレ比率（円グラフ用）のデータを部位ごとに集計してハッシュ化
    @chart_data = @workout_logs.group_by(&:body_part).to_h do |part, logs|
      [part, logs.sum { |log| log.weight * log.reps }]
    end
  end

  private

  # セキュリティ。ちゃんとworkout_formのデータがあるかのチェックと、日付、メニュー名、重量、回数の4つのデータだけを通過許可。
  def workout_form_params
    params.require(:workout_form).permit(
      :workout_date,
      :menu_type,
      sets_attributes: %i[id workout_type_id weight reps set_number menu_type body_part]
    )
  end
end
