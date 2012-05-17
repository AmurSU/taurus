# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120513111229) do

  create_table "buildings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "charge_cards", :force => true do |t|
    t.integer  "discipline_id"
    t.integer  "teaching_place_id"
    t.integer  "lesson_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hours_per_week"
    t.integer  "weeks_quantity"
    t.integer  "assistant_id"
    t.string   "editor_name"
    t.integer  "semester_id"
  end

  create_table "classrooms", :force => true do |t|
    t.integer  "building_id"
    t.integer  "department_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "capacity"
    t.boolean  "department_lock", :default => false
  end

  create_table "departments", :force => true do |t|
    t.integer  "faculty_id"
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gosinsp_code"
  end

  create_table "disciplines", :force => true do |t|
    t.integer  "department_id"
    t.string   "short_name"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faculties", :force => true do |t|
    t.string   "full_name"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.integer  "speciality_id"
    t.string   "name"
    t.integer  "forming_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "population"
  end

  create_table "jets", :force => true do |t|
    t.integer  "charge_card_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subgroups_quantity", :default => 0
  end

  create_table "lecturers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "whish"
  end

  create_table "lesson_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pairs", :force => true do |t|
    t.integer  "charge_card_id"
    t.integer  "classroom_id"
    t.integer  "timeslot_id"
    t.integer  "day_of_the_week"
    t.integer  "pair_number"
    t.integer  "week"
    t.date     "active_at"
    t.date     "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", :force => true do |t|
    t.integer  "year",                          :null => false
    t.integer  "number",                        :null => false
    t.boolean  "full_time",  :default => true,  :null => false
    t.date     "start"
    t.date     "end"
    t.boolean  "open",       :default => false, :null => false
    t.boolean  "freezed",    :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "semesters", ["year", "number", "full_time"], :name => "index_semesters_on_year_and_number_and_full_time", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "specialities", :force => true do |t|
    t.integer  "department_id"
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subgroups", :force => true do |t|
    t.integer  "jet_id"
    t.integer  "pair_id"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teaching_places", :force => true do |t|
    t.integer  "department_id"
    t.integer  "lecturer_id"
    t.integer  "position_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teaching_plans", :force => true do |t|
    t.integer  "speciality_id",                    :null => false
    t.integer  "discipline_id",                    :null => false
    t.integer  "course",                           :null => false
    t.integer  "semester",                         :null => false
    t.integer  "lections"
    t.integer  "practics"
    t.integer  "lab_works"
    t.boolean  "exam",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "type"
    t.integer  "department_id"
    t.string   "name"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
