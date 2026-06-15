class CreateWorkoutTemplateSets < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_template_sets do |t|
      t.references :workout_template, null: false, foreign_key: true
      t.string :menu_type
      t.integer :step_number
      t.float :default_weight
      t.integer :default_reps

      t.timestamps
    end
  end
end
