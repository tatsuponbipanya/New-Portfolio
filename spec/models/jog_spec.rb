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
end
