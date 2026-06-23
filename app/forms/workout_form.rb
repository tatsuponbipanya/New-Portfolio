# app/forms/workout_form.rb
class WorkoutForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # フォーム全体で共通する項目。attribute（データ型の指定）
  attribute :user_id, :integer
  attribute :workout_date, :datetime
  attribute :menu_type, :string

  # 各セットのデータを保持する配列。
  # これを書いておくだけで、外部（コントローラーなど）から @workout_form.sets_attributes = データの塊 という風に、
  # その物置きの中にデータを放り込んだり、逆に中身を取り出したりできるようになる。
  # 今回の場合、画面から送られてくる「1セット目：80kg/5回、2セット目：75kg/6回…」というセット情報の塊を、
  # 一時的にこの sets_attributes という名前の物置きに保管する。
  attr_accessor :sets_attributes

  # バリデーション（入力チェック）
  validates :menu_type, presence: true
  validates :workout_date, presence: true
  # 空白・片方未入力をブロック
  validate :validate_sets

  # データを保存するメソッド
  # 入力チェック（valid?）をして、もしダメ（unless）なら、この時点で処理を強制終了して false を返す
  def save
    return false unless valid?

    # トランザクション（エラーが起きたら全部取り消す安全装置）
    # これがないと、1セット目が通って2セット目でエラーが出た場合、1セット目の中途半端なデータが残ってしまう。
    ActiveRecord::Base.transaction do
      # ハッシュをキー（"0", "1", "2"）の順に正しくソートしてからループを回す。
      sorted_sets = sets_attributes.sort_by { |key, _| key.to_i }

      # sets_attributes に入ってきた各セットのデータをループで保存する。
      # この _ は「データは入ってくるけど、私は一切使わないから無視する！」という意味の変数名
      sorted_sets.each do |_, set_params|
        # 重量と回数の両方が入っているセットだけを保存。
        # create! の後ろについている !は、「もし保存に失敗したら、遠慮なく例外エラーを発生させてね」という合図。これによって、さっきの安全装置（トランザクション）がすぐに発動できるようになっている
        next unless set_params[:weight].present? && set_params[:reps].present?

        WorkoutLog.create!(
          user_id: user_id,
          workout_date: workout_date,
          menu_type: menu_type,
          weight: set_params[:weight],
          reps: set_params[:reps]
        )
      end
    end
    true # 全部のループが無事に終わったら「成功（true）」を返す

  # もし途中で、データベースの保存ルール違反（ActiveRecord::RecordInvalid）が起きた場合、それをキャッチしてe（error）に代入。
  rescue ActiveRecord::RecordInvalid => e
    # 発生したエラーメッセージを取得。:baseを指定すると、「特定の入力欄ではなく、このフォーム全体のエラーだよ！」という意味になり、特定の入力欄の横ではなく、画面の一番上とかにまとめて表示されるようになる。
    errors.add(:base, e.message)
    false
  end

  # 筋トレセット入力欄を生み出すeach ループに、入力エラー時でも正しいデータを届ける。
  def sets_attributes_for_render
    # 1. もしエラーで戻ってきて、送信されたセットデータ（sets_attributes）が存在する場合、
    if sets_attributes.present?
      # データの形を、ビューのループが処理しやすいように、mapとsortで配列に並び替えて送り返す。
      # （{"0"=>{"weight"=>"83"}, "1"=>{"weight"=>"80"}} の中身だけを、上から順に取り出す）
      # キーの"0"や"1"は文字なので、ソート出来るようにto_iで数字に変換。「_|」で一旦中身は無視。
      # ソート出来たら中身を回収。キーはもういらないので「|_」で無視。
      sets_attributes.sort_by { |key, _| key.to_i }.map { |_, value| value }
    else
      # 2. 一番最初に入力画面を開いた時（まだ何も送信してない時）は、
      # 1セット目の「真っ白な空っぽの箱」を1個だけ入れてビューに送り返す
      [{ 'weight' => nil, 'reps' => nil }]
    end
  end

  private

  # ja.yml の辞書を使ってエラーメッセージを出すバリデーション
  def validate_sets
    # セットのデータが空か、セットの重量とrepsが全て空の場合、エラーを表示して処理を終了。
    if sets_attributes.blank? || sets_attributes.values.all? { |set| set[:weight].blank? && set[:reps].blank? }
      # ja.yml の blank_sets を呼び出す
      errors.add(:base, :blank_sets)
      return
    end

    # &. は、ぼっち演算子。中身が空っぽ（nil）のオブジェクトに対してメソッドを呼び出しても、プログラムがクラッシュせずに、nilを返してスルーしてくれるので、つけておいた方が安全。
    # ここで入力されたデータを取り出す。
    sets_attributes&.each do |index, set_params|
      weight = set_params[:weight]
      reps = set_params[:reps]
      set_num = index.to_i + 1

      # 重量もrepsも両方空のセットは、スルー。
      next if weight.blank? && reps.blank?

      # 重量はあるが、repsが空の場合はエラー表示
      if weight.present? && reps.blank?
        # ja.yml の blank_reps を呼び出して、セット数を％{num}に挿入
        errors.add(:base, :blank_reps, num: set_num)
      end

      # 重量が空で、repsだけある場合もエラー表示
      if weight.blank? && reps.present?
        # ja.yml の blank_weight を呼び出して、セット数を％{num}に挿入
        errors.add(:base, :blank_weight, num: set_num)
      end
    end
  end
end
