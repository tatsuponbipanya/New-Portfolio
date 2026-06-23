class WorkoutTemplatesController < ApplicationController
  # ログインしていなかったら、ログイン画面へリダイレクト
  before_action :require_login
  # 編集(edit)、更新(update)、削除(destroy)をする前に、ターゲットのテンプレートをDBから見つけておく
  before_action :set_template, only: %i[edit update destroy]

  # テンプレート管理画面（一覧）を表示
  def index
    # ログイン中のユーザーのテンプレートをセット内容と一緒に全部持ってくる
    @templates = current_user.workout_templates.includes(:workout_template_sets)
  end

  # テンプレート新規作成画面を表示する処理
  def new
    # ログイン中のユーザーの空のテンプレート箱を生成
    @workout_template = current_user.workout_templates.build
    # 画面を開いたときに、最初から「1セット分」の空のセット入力欄を仕込んでおく
    1.times { @workout_template.workout_template_sets.build }
  end

  # 画面から送られてきたテンプレートをDBに保存する処理
  def create
    # 送られてきた種目名を、すべてのセットに裏側で一括コピーして保存
    copy_main_menu_to_all_sets

    @workout_template = current_user.workout_templates.build(workout_template_params)

    if @workout_template.save
      redirect_to root_path, notice: "マイテンプレート『#{@workout_template.name}』を登録しました"
    else
      # バグで戻ってきた時は、フォルダの構造に合わせて 'new' の画面を再描画する
      render :new, status: :unprocessable_entity
    end
  end

  # 編集画面を表示
  def edit
    # before_action（set_template）のおかげで、すでに @workout_template に編集したいデータが入っている。
  end

  # 編集した内容を上書き保存（更新）する処理
  def update
    # 編集画面で種目名が変わった場合も、すべてのセットに裏側で一括コピー
    copy_main_menu_to_all_sets

    if @workout_template.update(workout_template_params)
      # 保存が成功したら、管理画面（一覧）に戻る
      redirect_to manage_workout_templates_path, notice: "テンプレート『#{@workout_template.name}』を更新しました！"
    else
      # 入力エラーがあれば、編集画面（edit）をエラー付きで再描画する
      render :edit, status: :unprocessable_entity
    end
  end

  # テンプレート削除
  def destroy
    @workout_template.destroy
    redirect_to manage_workout_templates_path, notice: "テンプレート『#{@workout_template.name}』を削除しました。"
  end

  private

  # 選択したテンプレートのデータを、ログインユーザーの中から見つける
  def set_template
    @workout_template = current_user.workout_templates.find(params[:id])
  end

  # 送られてきた種目名を、すべてのセットに裏側で一括コピーして保存する
  def copy_main_menu_to_all_sets
    tp = params[:workout_template]
    return unless tp && tp[:workout_template_sets_attributes]

    # 1番目の行から選ばれた種目名を取得
    main_menu = tp[:workout_template_sets_attributes]['0'][:menu_type]
    # 2セット目以降の空っぽの種目名エリアに、同じ種目名を全部流し込む
    tp[:workout_template_sets_attributes].each do |_key, value|
      value[:menu_type] = main_menu
    end
  end

  # テンプレート用のセキュリティチェック（ストロングパラメータ）
  def workout_template_params
    params.require(:workout_template).permit(
      :name,
      # 編集画面でセットを削除できるようにするために、末尾に「:_destroy」を追加して許可。
      workout_template_sets_attributes: %i[id menu_type step_number default_weight default_reps _destroy]
    )
  end
end
