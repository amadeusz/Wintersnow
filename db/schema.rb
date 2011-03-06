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

ActiveRecord::Schema.define(:version => 20110304210626) do

  create_table "addresses", :force => true do |t|
    t.string   "klucz"
    t.string   "adres"
    t.datetime "data_mod"
    t.datetime "data_spr"
    t.string   "opis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "komunikaty"
    t.boolean  "blokada",               :default => false
    t.string   "xpath"
    t.string   "regexp"
    t.string   "css"
    t.boolean  "private"
    t.string   "last_content"
    t.string   "last_content_type"
    t.string   "last_content_checksum"
  end

  add_index "addresses", ["klucz"], :name => "index_addresses_on_klucz", :unique => true

  create_table "genotypes", :force => true do |t|
    t.string   "genotyp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.datetime "data"
    t.integer  "type"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.text     "tresc"
    t.datetime "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "address_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.integer "address_id"
    t.string  "opis"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "klucz"
    t.text     "obserwowane"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "haslo"
    t.boolean  "admin"
    t.string   "rss_pass"
    t.string   "fire_login"
    t.string   "fire_password"
    t.string   "water_login"
    t.string   "water_password"
    t.string   "air_login"
    t.string   "air_password"
    t.string   "earth_login"
    t.string   "earth_password"
  end

  add_index "users", ["id"], :name => "index_users_on_id", :unique => true

end
