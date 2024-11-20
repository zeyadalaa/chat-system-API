class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats, id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.integer :number, null: false
      t.string :application_token, null: false
      t.string :title, null: false
      t.integer :messages_count, default: 0, null: false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :chats, [:application_token, :number], unique: true, name: "index_chats_on_application_token_and_number"
    add_index :chats, :application_token, name: "index_chats_on_application_token"
    add_index :chats, :number, name: "index_chats_on_number"

    add_foreign_key :chats, :applications, column: "application_token", primary_key: "token", name: "fk_chats_to_applications"
  end
end
