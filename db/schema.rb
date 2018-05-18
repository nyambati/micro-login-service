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

ActiveRecord::Schema.define(version: 2018_05_23_155709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "userid"
    t.index ["role_id"], name: "index_assignments_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
  end

  create_table "users", primary_key: "userid", id: :string, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "confirmation_token_digest"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token_digest"
    t.string "lastname"
    t.string "firstname"
    t.index ["userid"], name: "index_users_on_userid"
  end

  add_foreign_key "assignments", "roles"
  add_foreign_key "assignments", "users", column: "userid", primary_key: "userid"
end
