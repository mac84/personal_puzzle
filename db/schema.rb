# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120831074013) do

  create_table "clients", :force => true do |t|
    t.string   "name",          :null => false
    t.integer  "standard_rate"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "user_id",       :null => false
  end

  create_table "completed_shifts", :force => true do |t|
    t.datetime "start_date", :null => false
    t.integer  "duration",   :null => false
    t.integer  "task_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "scheduled_shifts", :force => true do |t|
    t.integer  "task_id",    :null => false
    t.datetime "start_date", :null => false
    t.integer  "duration",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.integer  "hourly_rate"
    t.integer  "fee"
    t.datetime "deadline_date"
    t.datetime "date_finished"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "user_id"
    t.integer  "client_id"
    t.boolean  "archived",      :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "monday",                     :default => false
    t.boolean  "tuesday",                    :default => false
    t.boolean  "wednesday",                  :default => false
    t.boolean  "thursday",                   :default => false
    t.boolean  "friday",                     :default => false
    t.boolean  "saturday",                   :default => false
    t.boolean  "sunday",                     :default => false
    t.integer  "min_scheduled_shift_length", :default => 2
  end

  create_table "vacations", :force => true do |t|
    t.datetime "start_date", :null => false
    t.integer  "user_id",    :null => false
    t.datetime "end_date",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "work_shifts", :force => true do |t|
    t.time     "start_time", :null => false
    t.integer  "duration",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
