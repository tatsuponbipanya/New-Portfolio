require 'rails_helper'

RSpec.describe 'ユーザーログインの自動テスト', type: :system do
  let(:user) { User.create(email: 'test@example.com', password: 'password', password_confirmation: 'password', name: 'たつマジロ') }

  it '正しい情報を入力すると、ログインに成功してトップページにいける' do
    # 1. ログイン画面を開く
    visit login_path

    # 2. フォームにロボットが文字を自動入力する
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password'

    # 3. ログインボタンを自動でクリック
    click_button 'ログイン'

    # 4. ログイン後の画面に「ログインしました」などのメッセージが出ているか検証
    expect(page).to have_content 'ログインしました'
    
    # 5. 現在のURLが、ちゃんとトップページになっているか検証
    expect(current_path).to eq root_path
  end
end