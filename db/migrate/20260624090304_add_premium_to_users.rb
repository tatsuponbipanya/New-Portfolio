class AddPremiumToUsers < ActiveRecord::Migration[8.1]
  def change
    # default: false をつけて、最初はみんな一般会員にする
    add_column :users, :premium, :boolean, default: false
  end
end
