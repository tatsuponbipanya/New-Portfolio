require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  # テスト用のユーザーを準備
  let(:user) do
    User.create!(
      name: 'たつマジロ',
      email: 'test@example.com',
      password: 'password123'
    )
  end

  before do
    # ログイン状態を作る。
    # allow_any_instance_of(ApplicationController) = すべてのコントローラーの基礎になってる ApplicationController に対して、「ちょっと言うこと聞いて！」と許可（allow）を出す。
    # .to receive(:current_user) = もしコードの中で current_user というメソッドが呼び出された（メッセージを受け取った）ら、
    # .and_return(user) = 本物のログイン処理はスキップして、用意しておいたテスト用ユーザー（user）を送り返す
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "ヘッダーとダッシュボード画面のアクセス" do
    it "各ページへのリンクが正しく表示されていること" do
      # 1. ダッシュボードのパスへアクセス
      get root_path

      # 2. 画面の表示が成功（200 OK）することを確認
      expect(response).to have_http_status(:success)

      # ヘッダー共通部分のテスト
      # ロゴ（MUSCLE_LOG）がトップページへのリンクになっているか
      expect(response.body).to include(root_path)
      # ヘッダーにログイン中のユーザー名が表示されているか
      expect(response.body).to include('たつマジロ')

      # 3. HTMLの中に、正しいリンク（href）が含まれているかをチェック
      # 筋トレ関係のリンク
      expect(response.body).to include(user_workout_logs_path(user))
      expect(response.body).to include(new_workout_template_path)
      expect(response.body).to include(manage_workout_templates_path)
      expect(response.body).to include(user_workout_logs_page_path(user))
      expect(response.body).to include(analytics_path(user))
      expect(response.body).to include(user_workout_logs_page_path(user))

      # ランニング関係のリンク
      expect(response.body).to include(new_user_jog_path(user))
      expect(response.body).to include(user_jogs_path(user))
      expect(response.body).to include(new_shoe_path)
      expect(response.body).to include(user_shoes_path(user))

      # アカウント関係のリンク
      expect(response.body).to include(users_path)
      expect(response.body).to include(user_path(user))
    end
  end
end