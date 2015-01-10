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

ActiveRecord::Schema.define(version: 20140802092139) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "plperl"

  create_table "comments", force: :cascade do |t|
    t.integer "domain_id",                 null: false
    t.string  "name",        limit: 255,   null: false
    t.string  "type",        limit: 10,    null: false
    t.integer "modified_at",               null: false
    t.string  "account",     limit: 40
    t.string  "comment",     limit: 65535, null: false
  end

  add_index "comments", ["domain_id", "modified_at"], name: "comments_order_idx", using: :btree
  add_index "comments", ["domain_id"], name: "comments_domain_id_idx", using: :btree
  add_index "comments", ["name", "type"], name: "comments_name_type_idx", using: :btree

  create_table "cryptokeys", force: :cascade do |t|
    t.integer "domain_id"
    t.integer "flags",     null: false
    t.boolean "active"
    t.text    "content"
  end

  add_index "cryptokeys", ["domain_id"], name: "domainidindex", using: :btree

  create_table "domainmetadata", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "kind",      limit: 16
    t.text    "content"
  end

  add_index "domainmetadata", ["domain_id"], name: "domainidmetaindex", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string  "name",            limit: 255,                    null: false
    t.string  "master",          limit: 128
    t.integer "last_check"
    t.string  "type",            limit: 6,   default: "MASTER", null: false
    t.integer "notified_serial"
    t.string  "account",         limit: 40
  end

  add_index "domains", ["name"], name: "name_index", unique: true, using: :btree

  create_table "domains_users", id: false, force: :cascade do |t|
    t.integer "domain_id"
    t.integer "user_id"
  end

  add_index "domains_users", ["domain_id", "user_id"], name: "index_domains_users_on_domain_id_and_user_id", unique: true, using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "name",        limit: 255
    t.string   "type",        limit: 10
    t.string   "content",     limit: 65535
    t.integer  "ttl"
    t.integer  "prio"
    t.string   "ordername",   limit: 255
    t.boolean  "auth",                      default: true
    t.datetime "change_date"
    t.boolean  "disabled",                  default: false
    t.string   "token",       limit: 255
  end

  add_index "records", ["domain_id", "ordername"], name: "recordorder", using: :btree
  add_index "records", ["domain_id"], name: "domain_id", using: :btree
  add_index "records", ["name", "type"], name: "nametype_index", using: :btree
  add_index "records", ["name"], name: "rec_name_index", using: :btree

  create_table "supermasters", primary_key: "ip", force: :cascade do |t|
    t.string "nameserver", limit: 255, null: false
    t.string "account",    limit: 40
  end

  create_table "tsigkeys", force: :cascade do |t|
    t.string "name",      limit: 255
    t.string "algorithm", limit: 50
    t.string "secret",    limit: 255
  end

  add_index "tsigkeys", ["name", "algorithm"], name: "namealgoindex", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "password_digest",    limit: 255
    t.boolean  "admin",                          default: false
    t.string   "default_primary",    limit: 255
    t.string   "default_postmaster", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "comments", "domains", name: "domain_exists", on_delete: :cascade
  add_foreign_key "cryptokeys", "domains", name: "cryptokeys_domain_id_fkey", on_delete: :cascade
  add_foreign_key "domainmetadata", "domains", name: "domainmetadata_domain_id_fkey", on_delete: :cascade
  add_foreign_key "domains_users", "domains", name: "domain_exists", on_delete: :cascade
  add_foreign_key "domains_users", "users", name: "user_exists", on_delete: :cascade
  add_foreign_key "records", "domains", name: "domain_exists", on_delete: :cascade
end
