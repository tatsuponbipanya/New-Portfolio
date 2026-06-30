require 'rails_helper'

RSpec.describe Shoe, type: :model do
  # FactoryBotからテスト用データ読み込み
  let(:shoe) { create(:shoe) }

  # データを空（nil）にしたり上書きして実験したい時用
  # shoe_idだけはFactoryのjogに含まれていないので、merge（合併）して足す必要がある。
  # attributes_forはデータベースに保存せずにデータだけ持って来れる。createはデータベースに保存する。
  let(:valid_attributes) { attributes_for(:shoe).merge(user_id: shoe.user_id) }

  describe 'validations' do
    # データがバッチリなら有効
    it 'is valid with valid attributes' do
      expect(shoe).to be_valid
    end

    # 名前がないと無効
    it 'is invalid without a name' do
      invalid_shoe = Shoe.new(valid_attributes.merge(name: nil))
      expect(invalid_shoe).not_to be_valid
    end

    # sizeが0以下なら無効
    it 'is invalid with a size of 0 or less' do
      invalid_shoe = Shoe.new(valid_attributes.merge(size: 0))
      expect(invalid_shoe).not_to be_valid

      invalid_shoe = Shoe.new(valid_attributes.merge(size: -50))
      expect(invalid_shoe).not_to be_valid
    end

    # widthが未入力なら無効
    it 'is invalid without a width' do
      invalid_shoe = Shoe.new(valid_attributes.merge(width: nil))
      expect(invalid_shoe).not_to be_valid
    end

    # bought_onが未入力なら無効
    it 'is invalid without a bought_on' do
      invalid_shoe = Shoe.new(valid_attributes.merge(bought_on: nil))
      expect(invalid_shoe).not_to be_valid
    end

    # bought_onが未来の日付の場合は無効
    it 'is invalid with a future bought_on date' do
      invalid_shoe = Shoe.new(valid_attributes.merge(bought_on: Date.tomorrow))
      expect(invalid_shoe).not_to be_valid
    end
  end
end
