class AddIntroductionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :introduction, :text
  end
end
