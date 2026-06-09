# app/forms/workout_form.rb
class WorkoutForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # フォーム全体で共通する項目。attribute（データ型の指定）
  attribute :user_id, :integer
  attribute :workout_date, :datetime
  attribute :menu_type, :string

  # 各セットのデータを保持する配列
  # これを書いておくだけで、外部（コントローラーなど）から @workout_form.sets_attributes = データの塊 っていう風に、その物置きの中にデータを放り込んだり、逆に中身を取り出したりできるようになる
  # 今回の場合、画面から送られてくる「1セット目：80kg/5回、2セット目：75kg/6回…」というごちゃっとしたセット情報の塊を、一時的にこの sets_attributes という名前の物置きに保管する
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
    # これがないと1セット目が通って2セット目でエラーが出た場合、1セット目の中途半端なデータが残ってしまう。
    ActiveRecord::Base.transaction do
      # sets_attributes に入ってきた各セットのデータをループで保存する
      # この _ は「データは入ってくるけど、私は一切使わないから無視する！」という意味の変数名
      sets_attributes.each do |_, set_params|
        # 重量と回数の両方が入っているセットだけを保存する
        # create! の後ろについている !は、「もし保存に失敗したら、遠慮なく例外エラーを発生させてね」という合図。これによって、さっきの安全装置（トランザクション）がすぐに発動できるようになっている
        if set_params[:weight].present? && set_params[:reps].present?
          WorkoutLog.create!(
            user_id: user_id,
            workout_date: workout_date,
            menu_type: menu_type,
            weight: set_params[:weight],
            reps: set_params[:reps]
          )
        end
      end
    end
    true # 全部のループが無事に終わったら「成功（true）」を返す
  rescue ActiveRecord::RecordInvalid
    false # もし途中で例外エラーが起きたら、ここへワープして「失敗（false）」を返す(入力画面に戻る)
          # ActiveRecord::RecordInvalid：数あるエラーの中でも「データベースの保存ルールに違反した！」という種類のエラーのこと。
  end

  private

  # ja.yml の辞書を使ってエラーメッセージを出すバリデーション
  def validate_sets
    if sets_attributes.blank? || sets_attributes.values.all? { |set| set[:weight].blank? && set[:reps].blank? }
      # ja.yml の blank_sets を呼び出す
      errors.add(:base, :blank_sets)
      return
    end

    sets_attributes.each do |index, set_params|
      weight = set_params[:weight]
      reps = set_params[:reps]
      set_num = index.to_i + 1

      next if weight.blank? && reps.blank?

      if weight.present? && reps.blank?
        # ja.yml の blank_reps を呼び出して、セット数を％{num}に挿入
        errors.add(:base, :blank_reps, num: set_num)
      end

      if weight.blank? && reps.present?
        # ja.yml の blank_weight を呼び出して、セット数を％{num}に挿入
        errors.add(:base, :blank_weight, num: set_num)
      end
    end
  end
end