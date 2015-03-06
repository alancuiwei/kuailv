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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150306080843) do

  create_table "activities", force: :cascade do |t|
    t.string   "start_city",      limit: 255
    t.string   "end_city",        limit: 255
    t.date     "start_time"
    t.date     "end_time"
    t.string   "founder",         limit: 255
    t.string   "f_homepage",      limit: 255
    t.string   "f_wechatid",      limit: 255
    t.text     "remarks",         limit: 65535
    t.string   "f_weiboid",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",          limit: 255
    t.string   "mobile",          limit: 255
    t.string   "qq",              limit: 255
    t.integer  "beauty",          limit: 4
    t.string   "f_wechatencrypt", limit: 255
    t.integer  "result",          limit: 4
  end

  add_index "activities", ["f_homepage"], name: "homeidex", unique: true, using: :btree

  create_table "activitiesbackup", id: false, force: :cascade do |t|
    t.integer  "id",              limit: 4,     default: 0, null: false
    t.string   "start_city",      limit: 255
    t.string   "end_city",        limit: 255
    t.date     "start_time"
    t.date     "end_time"
    t.string   "founder",         limit: 255
    t.string   "f_homepage",      limit: 255
    t.string   "f_wechatid",      limit: 255
    t.text     "remarks",         limit: 65535
    t.string   "f_weiboid",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",          limit: 255
    t.string   "mobile",          limit: 255
    t.string   "qq",              limit: 255
    t.integer  "beauty",          limit: 4
    t.string   "f_wechatencrypt", limit: 255
    t.integer  "result",          limit: 4
  end

  add_index "activitiesbackup", ["id"], name: "ad", unique: true, using: :btree

  create_table "invitetables", force: :cascade do |t|
    t.string   "inviteid",   limit: 255
    t.string   "wechatid",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "statistics", force: :cascade do |t|
    t.date     "recorddate"
    t.integer  "totalnum",   limit: 4
    t.integer  "deltanum",   limit: 4
    t.integer  "weibonum",   limit: 4
    t.integer  "weixinnum",  limit: 4
    t.integer  "qyernum",    limit: 4
    t.integer  "autonum",    limit: 4
    t.integer  "A100",       limit: 4
    t.integer  "A101",       limit: 4
    t.integer  "A102",       limit: 4
    t.integer  "A103",       limit: 4
    t.integer  "A104",       limit: 4
    t.integer  "A105",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "tweibonum",  limit: 4
    t.integer  "tweixinnum", limit: 4
    t.integer  "tqyernum",   limit: 4
    t.integer  "tautonum",   limit: 4
    t.integer  "TA100",      limit: 4
    t.integer  "TA101",      limit: 4
    t.integer  "TA102",      limit: 4
    t.integer  "TA103",      limit: 4
    t.integer  "TA104",      limit: 4
    t.integer  "TA105",      limit: 4
    t.integer  "ytotalnum",  limit: 4
    t.integer  "ydeltanum",  limit: 4
  end

  add_index "statistics", ["recorddate"], name: "datediff", unique: true, using: :btree

end
