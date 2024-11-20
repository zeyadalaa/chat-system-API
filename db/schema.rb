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

ActiveRecord::Schema[7.0].define(version: 2024_11_20_051316) do
  create_table "applications", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "deviceName", null: false
    t.string "token", null: false
    t.integer "chats_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_applications_on_token", unique: true
  end

  create_table "chats", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "number", null: false
    t.string "application_token", null: false
    t.string "title", null: false
    t.integer "messages_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_token", "number"], name: "index_chats_on_application_token_and_number", unique: true
    t.index ["application_token"], name: "index_chats_on_application_token"
    t.index ["number"], name: "index_chats_on_number"
  end

  create_table "messages", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "number", null: false
    t.integer "chat_number", null: false
    t.string "application_token", null: false
    t.string "content", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_token", "number", "chat_number"], name: "index_messages_on_application_token_number_and_chat_number", unique: true
    t.index ["chat_number"], name: "fk_messages_to_chats_by_number"
  end

  add_foreign_key "chats", "applications", column: "application_token", primary_key: "token", name: "fk_chats_to_applications"
  add_foreign_key "messages", "applications", column: "application_token", primary_key: "token", name: "fk_messages_to_applications"
  add_foreign_key "messages", "chats", column: "chat_number", primary_key: "number", name: "fk_messages_to_chats_by_number"
end
