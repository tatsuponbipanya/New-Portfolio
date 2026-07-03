require 'rails_helper'

RSpec.describe WorkoutLog, type: :model do
  # FactoryBotからテスト用データ読み込み
  let(:workout_log) { create(:workout_log) }

  # データを空（nil）にしたり上書きして実験したい時用
  # attributes_forはデータベースに保存せずにデータだけ持って来れる。createはデータベースに保存する。
  let(:valid_attributes) { attributes_for(:workout_log).merge(user_id: workout_log.user_id) }

  describe 'validations' do
    # データがバッチリなら有効
    it 'is valid with valid attributes' do
      expect(workout_log).to be_valid
    end

    # 種目名が空の場合は無効
    it 'is invalid without menu_type' do
      invalid_log = WorkoutLog.new(valid_attributes.merge(menu_type: ''))
      expect(invalid_log).not_to be_valid
    end
  end

  # === 部位判定メソッドのテスト ===
  describe '#body_part' do
    it 'ベンチプレスの場合、胸が返ってくること' do
      log1 = WorkoutLog.new(menu_type: 'ベンチプレス')
      expect(log1.body_part).to eq '胸'
    end

    it 'チンニングの場合、背中が返ってくること' do
      log = WorkoutLog.new(menu_type: 'チンニング')
      expect(log.body_part).to eq '背中'
    end

    it 'スクワットの場合、脚が返ってくること' do
      expect(WorkoutLog.new(menu_type: 'スクワット').body_part).to eq '脚'
    end

    it 'ショルダープレスの場合、肩が返ってくること' do
      expect(WorkoutLog.new(menu_type: 'ショルダープレス').body_part).to eq '肩'
    end

    it 'アームカールの場合、腕が返ってくること' do
      expect(WorkoutLog.new(menu_type: 'アームカール').body_part).to eq '腕'
    end

    # 判定にヒットしない種目名は「その他」に振り分けられること
    it '該当しない種目名の場合、その他が返ってくること' do
      expect(WorkoutLog.new(menu_type: 'なわとび').body_part).to eq 'その他'
    end
  end

  # === 1RM計算メソッドのテスト ===
  describe '#estimated_1rm' do
    context '重量と回数が正しく入力されているとき' do
      it '1レップのときは、計算せずに元の重量がそのまま返ってくること' do
        log = WorkoutLog.new(weight: 83.0, reps: 1)
        expect(log.estimated_1rm).to eq 83.0
      end

      it '複数レップ（例: 5レップ）のときは、正しく1RMの計算が行われること' do
        # 83kg * (1 + 5 / 30.0) = 83 * 1.16666... = 96.8333... => 四捨五入して 96.8
        log = WorkoutLog.new(weight: 83.0, reps: 5)
        expect(log.estimated_1rm).to eq 96.8
      end
    end

    context '重量や回数が空白のとき' do
      it 'エラーにならずに 0.0 が返ってくること' do
        log_nil = WorkoutLog.new(weight: nil, reps: nil)
        expect(log_nil.estimated_1rm).to eq 0.0
      end

      # 重量だけ・回数だけ入っている片方欠けのケースでも 0.0 を返すこと
      it '重量だけ入っていて回数が空のときも 0.0 が返ってくること' do
        expect(WorkoutLog.new(weight: 80.0, reps: nil).estimated_1rm).to eq 0.0
      end
    end
  end
end
