require 'rails_helper'

RSpec.describe User, type: :model do
  # FactoryBotからテスト用データ読み込み
  let(:user) { create(:user) }

  # データを空（nil）にしたり上書きして実験したい時用
  # attributes_forはデータベースに保存せずにデータだけ持って来れる。createはデータベースに保存する。
  let(:valid_attributes) { attributes_for(:user) }

  describe 'validations' do
    # データがバッチリなら有効
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    # nameが未入力なら無効
    it 'is invalid without a name' do
      invalid_user = User.new(valid_attributes.merge(name: nil))
      expect(invalid_user).not_to be_valid
    end

    # emailが未入力なら無効
    it 'is invalid without a email' do
      invalid_user = User.new(valid_attributes.merge(email: nil))
      expect(invalid_user).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      user # 先に1人作っておく。
      invalid_user = User.new(valid_attributes.merge(email: user.email))
      expect(invalid_user).not_to be_valid
    end
  end
end
