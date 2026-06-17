class AddHeartRateToJogs < ActiveRecord::Migration[8.1]
  def change
    add_column :jogs, :heart_rate, :integer
  end
end
