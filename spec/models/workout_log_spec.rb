require 'rails_helper'

RSpec.describe WorkoutLog, type: :model do
  # テスト用のユーザーを準備
  let(:user) do
    User.create!(
      name: 'たつマジロ',
      email: 'test@example.com',
      password: 'password123'
    )
  end

  it '全ての項目が入力されていれば有効であること' do
    workout_log = WorkoutLog.new(
      user_id: user.id,
      workout_date: Date.today,
      menu_type: 'ベンチプレス',
      weight: 83.0,
      reps: 1
    )
    expect(workout_log).to be_valid
  end

  it '種目名が未入力の場合は無効であること' do
    workout_log = WorkoutLog.new(
      user_id: user.id,
      workout_date: Date.today,
      menu_type: '', # 未入力
      weight: 83.0,
      reps: 1
    )
    expect(workout_log).not_to be_valid
  end

  # === 部位判定メソッドのテスト ===
  describe '#body_part' do
    it 'ベンチプレスやの場合、胸が返ってくること' do
      log1 = WorkoutLog.new(menu_type: 'ベンチプレス')

      expect(log1.body_part).to eq '胸'
    end

    it 'チンニングの場合、背中が返ってくること' do
      log = WorkoutLog.new(menu_type: 'チンニング')
      expect(log.body_part).to eq '背中'
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
    end
  end
end
