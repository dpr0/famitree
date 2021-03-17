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

ActiveRecord::Schema.define(version: 2021_03_17_090000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "family_trees", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "family_trees_users", force: :cascade do |t|
    t.integer "family_tree_id"
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at"
    t.index ["family_tree_id", "user_id"], name: "index_family_trees_users_on_family_tree_id_and_user_id"
    t.index ["user_id", "family_tree_id"], name: "index_family_trees_users_on_user_id_and_family_tree_id"
  end

  create_table "persons", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "maiden_name"
    t.integer "sex_id"
    t.integer "father_id"
    t.integer "mother_id"
    t.integer "family_tree_id"
    t.date "birthdate"
    t.date "deathdate"
    t.string "address"
    t.string "contact"
    t.string "document"
    t.string "info"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "relation_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
  end

  create_table "relations", force: :cascade do |t|
    t.integer "person_id"
    t.integer "relation_person_id"
    t.integer "relation_type_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "code"
    t.string "name"
  end

  create_table "sex", force: :cascade do |t|
    t.string "code"
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "provider"
    t.string "token"
    t.integer "person_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "authorizations", "users"
end
