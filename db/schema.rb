# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100907231925) do

  create_table "addresses", :force => true do |t|
    t.string   "klucz"
    t.string   "adres"
    t.datetime "data_mod"
    t.datetime "data_spr"
    t.string   "opis"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "komunikaty"
    t.boolean  "blokada",    :default => false
  end

  add_index "addresses", ["klucz"], :name => "index_addresses_on_klucz", :unique => true

  create_table "genotypes", :force => true do |t|
    t.string   "genotyp",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  add_index "genotypes", ["genotyp"], :name => "index_genotypes_on_genotyp", :unique => true

  create_table "messages", :force => true do |t|
    t.text     "tresc"
    t.datetime "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "klucz"
    t.text     "obserwowane"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "haslo"
  end

  add_index "users", ["id"], :name => "index_users_on_id", :unique => true

end
