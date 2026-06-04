class CreateWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_logs do |t|
      t.date :workout_date
      t.string :menu_type
      t.float :weight
      t.integer :reps

      t.timestamps
    end
  end
end
