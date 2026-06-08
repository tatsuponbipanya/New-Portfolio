class ChangeWorkoutDateToDatetimeInWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    change_column :workout_logs, :workout_date, :datetime
  end
end
