class AddUserIdToWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    add_reference :workout_logs, :user, foreign_key: true
  end
end
