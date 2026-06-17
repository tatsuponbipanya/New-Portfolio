class CreateShoes < ActiveRecord::Migration[8.1]
  def change
    create_table :shoes do |t|
      t.string :name
      t.float :total_distance
      t.float :target_distance

      t.timestamps
    end
  end
end
