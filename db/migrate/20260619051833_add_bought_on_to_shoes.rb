class AddBoughtOnToShoes < ActiveRecord::Migration[8.1]
  def change
    add_column :shoes, :bought_on, :date
  end
end
