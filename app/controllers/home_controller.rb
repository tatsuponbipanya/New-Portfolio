# app/controllers/home_controller.rb
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
      redirect_to user_path(current_user), notice: "筋トレが記録されました。"
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
    # まずgroup_byで種目ごとにデータを分け、transform_valuesで種目名（キー）は固定したまま、中のデータを総入れ替えする。
    @chart_data_by_menu = @workout_logs.group_by(&:menu_type).transform_values do |logs|
      # 「日付（workout_date）」ごとにデータをグループ化（同日の複数セットをまとめる）
      # ここでもtransform_valuesを使い、日付（キー）は固定のまま、中身を「その日の1RM最大値」に書き換える。
      logs.group_by { |log| log.workout_date.to_date }.transform_values do |daily_logs|
        # 同日のすべてのセット（daily_logs）から、それぞれの推定1RMを計算して再配列化し、最大値を取得。
        daily_logs.map(&:estimated_1rm).max
      end
    end
  end

  # テンプレート作成画面を表示する処理
  def new_template
    # ログイン中のユーザーの空のテンプレート箱を生成
    @workout_template = current_user.workout_templates.build
    
    # 画面を開いたときに、最初から「3セット分」の空のセット入力欄を仕込んでおく
    1.times { @workout_template.workout_template_sets.build }
  end

  # 画面から送られてきたテンプレートをDBに保存する処理
  def create_template
    @user = current_user || User.first
    
    # 送られてきた種目名を、すべてのセットに裏側で一括コピーして保存
    tp = params[:workout_template]
    if tp && tp[:workout_template_sets_attributes]
      # 1番目の行から選ばれた種目名を取得
      main_menu = tp[:workout_template_sets_attributes]["0"][:menu_type]
      # 2セット目以降の空っぽの種目名エリアに、同じ種目名を全部流し込む
      tp[:workout_template_sets_attributes].each do |key, value|
        value[:menu_type] = main_menu
      end
    end

    @workout_template = @user.workout_templates.build(workout_template_params)

    if @workout_template.save
      redirect_to root_path, notice: "マイテンプレート『#{@workout_template.name}』を登録しました"
    else
      render :new_template, status: :unprocessable_entity
    end
  end

  # テンプレート管理画面（一覧）を表示
  def index_templates
    # ログイン中のユーザーのテンプレートをセット内容と一緒に全部持ってくる
    @templates = current_user.workout_templates.includes(:workout_template_sets)
  end

  # テンプレート削除
  def destroy_template
    @template = current_user.workout_templates.find(params[:id])
    @template.destroy
    redirect_to manage_workout_templates_path, notice: "テンプレート『#{@template.name}』を削除しました"
  end

  #カプセル化（隠蔽）。外からURL（インターネット）経由で呼び出せないメソッド。
  #ハッカーがURLの入力を工夫して、以下のメソッドを直接狙い撃ちしてきても無効に出来る。
  private

  #セキュリティ。ちゃんとworkout_formのデータがあるかのチェックと、日付、メニュー名、重量、回数の4つのデータだけを通過許可。
  #これがないと、admin: true（自分を管理者権限にする）などのデータが通ってしまう。
  def workout_form_params
    params.require(:workout_form).permit(
      :workout_date,
      :menu_type,
      sets_attributes: [:weight, :reps]
    )
  end

  # テンプレート用のセキュリティチェック
  def workout_template_params
    params.require(:workout_template).permit(
      :name,
      # テンプレート名と一緒に、3セット分の子データ（重量・回数・種目名など）もまとめて通過許可
      workout_template_sets_attributes: [:id, :menu_type, :step_number, :default_weight, :default_reps, :_destroy]
    )
  end
end