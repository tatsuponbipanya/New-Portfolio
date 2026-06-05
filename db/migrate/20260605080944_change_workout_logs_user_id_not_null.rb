class ChangeWorkoutLogsUserIdNotNull < ActiveRecord::Migration[8.1]
  def change
    # 既存のデータを守りつつ、これからは user_id が必須だと定義
    change_column_null :workout_logs, :user_id, false
  end
end
