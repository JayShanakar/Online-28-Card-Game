# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "cards", :force => true do |t|
    t.string   "suit"
    t.string   "cardno"
    t.integer  "points"
    t.integer  "playerid"
    t.boolean  "dealstatus"
    t.boolean  "playstatus"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", :force => true do |t|
    t.integer  "trickid"
    t.integer  "gameid"
    t.integer  "playerid"
    t.integer  "moveno"
    t.string   "cardsuit"
    t.string   "cardno"
    t.integer  "cardpoints"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", :force => true do |t|
    t.integer  "playerAid"
    t.integer  "playerBid"
    t.integer  "playerCid"
    t.integer  "playerDid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tricks", :force => true do |t|
    t.integer  "trickno"
    t.integer  "trickwinnerid"
    t.integer  "trickleadid"
    t.integer  "gameid"
    t.integer  "trickpoints"
    t.string   "tricksuit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
