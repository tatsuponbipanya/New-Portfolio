class User < ApplicationRecord
    #パスワード暗号化の呪文
    has_secure_password
end
