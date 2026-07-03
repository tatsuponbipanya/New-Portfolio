require 'rails_helper'

RSpec.describe Jog, type: :model do
  # FactoryBotからテスト用データ読み込み
  let(:jog) { create(:jog) }

  # データを空（nil）にしたり上書きして実験したい時用
  # shoe_idだけはFactoryのjogに含まれていないので、merge（合併）して足す必要がある。
  # attributes_forはデータベースに保存せずにデータだけ持って来れる。createはデータベースに保存する。
  let(:valid_attributes) { attributes_for(:jog).merge(shoe_id: jog.shoe_id) }

  # こっからテスト
  describe 'validations' do
    # 有効な（データが揃った）属性セットを持っていれば、それは有効である
    it 'is valid with valid attributes' do
      expect(jog).to be_valid
    end

    # 日付が未入力なら、有効でない
    it 'is invalid without a date' do
      valid_attributes[:date] = nil
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid
    end

    # 距離が0以下のときは無効
    it 'is invalid with a distance of 0 or less' do
      valid_attributes[:distance] = 0.0
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid

      valid_attributes[:distance] = -1.0
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid
    end

    # 分（time_minute）の範囲チェック（0以上60未満）
    it 'is invalid with a time_minute of 60 or more' do
      valid_attributes[:time_minute] = 60
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid

      valid_attributes[:time_minute] = 100
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid
    end

    # 心拍数（heart_rate）に文字が入った時のチェック
    it 'is invalid with non-integer heart_rate' do
      valid_attributes[:heart_rate] = '自然が磨いた天然水'
      invalid_jog = Jog.new(valid_attributes)
      expect(invalid_jog).not_to be_valid
    end
  end

  # === ペース自動計算（before_save）のテスト ===
  describe 'ペースの自動計算' do
    let(:shoe) { create(:shoe) }

    # 10kmを50分ちょうどで走った場合、1kmあたり5分00秒になること
    it '距離とタイムから1kmあたりのペースが計算されること' do
      jog = Jog.create!(
        shoe: shoe, distance: 10.0, date: Date.current,
        time_hour: 0, time_minute: 50, time_second: 0
      )
      # 3000秒 ÷ 10km = 300秒/km = 5分00秒
      expect(jog.pace_minute).to eq 5
      expect(jog.pace_second).to eq 0
    end

    # 端数が出るケース（5kmを26分ちょうど → 312秒/km = 5分12秒）
    it '端数が出る場合も分・秒に正しく分解されること' do
      jog = Jog.create!(
        shoe: shoe, distance: 5.0, date: Date.current,
        time_hour: 0, time_minute: 26, time_second: 0
      )
      # 1560秒 ÷ 5km = 312秒/km = 5分12秒
      expect(jog.pace_minute).to eq 5
      expect(jog.pace_second).to eq 12
    end

    # 画面から送られてきたペースの値は、保存時に必ず再計算で上書きされること
    it '入力済みのペースは保存時に再計算で上書きされること' do
      jog = Jog.create!(
        shoe: shoe, distance: 10.0, date: Date.current,
        time_hour: 0, time_minute: 50, time_second: 0,
        pace_minute: 99, pace_second: 99
      )
      expect(jog.pace_minute).to eq 5
      expect(jog.pace_second).to eq 0
    end
  end

  # === シューズ累計距離の加減算（after_create / after_destroy）のテスト ===
  describe 'シューズの累計距離との連動' do
    let(:shoe) { create(:shoe, total_distance: 100.0) }

    # 新規作成時に、走った距離がシューズの累計に加算されること
    it 'Jog作成時にシューズの累計距離が加算されること' do
      expect do
        create(:jog, shoe: shoe, distance: 12.0)
      end.to change { shoe.reload.total_distance }.from(100.0).to(112.0)
    end

    # 削除時に、その分がシューズの累計から減算されること
    it 'Jog削除時にシューズの累計距離が減算されること' do
      jog = create(:jog, shoe: shoe, distance: 12.0)
      expect do
        jog.destroy!
      end.to change { shoe.reload.total_distance }.from(112.0).to(100.0)
    end

    # 減算しても0未満にはならず、0.0で止まること
    it '減算結果がマイナスになる場合は0.0で止まること' do
      jog = create(:jog, shoe: shoe, distance: 12.0)
      # 別経路でシューズの累計を小さい値に更新してから削除する
      shoe.update!(total_distance: 5.0)
      jog.destroy!
      expect(shoe.reload.total_distance).to eq 0.0
    end
  end
end
