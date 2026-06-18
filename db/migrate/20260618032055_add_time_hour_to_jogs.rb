class AddTimeHourToJogs < ActiveRecord::Migration[8.1]
  def change
    add_column :jogs, :time_hour, :integer
  end
end
