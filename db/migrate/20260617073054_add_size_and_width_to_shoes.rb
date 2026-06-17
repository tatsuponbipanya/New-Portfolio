class AddSizeAndWidthToShoes < ActiveRecord::Migration[8.1]
  def change
    add_column :shoes, :size, :float
    add_column :shoes, :width, :string
  end
end
