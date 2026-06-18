class AddUserIdToShoes < ActiveRecord::Migration[8.1]
  def change
    add_reference :shoes, :user, null: false, foreign_key: true
  end
end
