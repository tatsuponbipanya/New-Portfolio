# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_18_032055) do
  create_table "jogs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.float "distance"
    t.integer "heart_rate"
    t.text "memo"
    t.integer "pace_minute"
    t.integer "pace_second"
    t.integer "shoe_id", null: false
    t.integer "time_hour"
    t.integer "time_minute"
    t.integer "time_second"
    t.datetime "updated_at", null: false
    t.index ["shoe_id"], name: "index_jogs_on_shoe_id"
  end

  create_table "shoes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.float "size"
    t.float "target_distance"
    t.float "total_distance"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "width"
    t.index ["user_id"], name: "index_shoes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "introduction"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "workout_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "menu_type"
    t.integer "reps"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.float "weight"
    t.datetime "workout_date"
    t.index ["user_id"], name: "index_workout_logs_on_user_id"
  end

  create_table "workout_template_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "default_reps"
    t.float "default_weight"
    t.string "menu_type"
    t.integer "step_number"
    t.datetime "updated_at", null: false
    t.integer "workout_template_id", null: false
    t.index ["workout_template_id"], name: "index_workout_template_sets_on_workout_template_id"
  end

  create_table "workout_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_workout_templates_on_user_id"
  end

  add_foreign_key "jogs", "shoes"
  add_foreign_key "shoes", "users"
  add_foreign_key "workout_logs", "users"
  add_foreign_key "workout_template_sets", "workout_templates"
  add_foreign_key "workout_templates", "users"
end
