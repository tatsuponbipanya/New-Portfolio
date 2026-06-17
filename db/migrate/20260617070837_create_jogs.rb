class CreateJogs < ActiveRecord::Migration[8.1]
  def change
    create_table :jogs do |t|
      t.float :distance
      t.integer :time_minute
      t.integer :time_second
      t.integer :pace_minute
      t.integer :pace_second
      t.text :memo
      t.date :date
      t.references :shoe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
