class User < ApplicationRecord
    #パスワード暗号化の呪文
    has_secure_password

    #ユーザーは複数の記録を持っているという宣言
    #dependent: :destroyをつけることでユーザーを消す時、データも一緒に消せる。
    has_many :workout_logs, dependent: :destroy

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
end
