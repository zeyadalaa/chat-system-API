class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.integer :number, null: false
      t.integer :chat_number, null: false
      t.string :application_token, null: false
      t.string :content, default: "", null: false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :messages, [:application_token, :number, :chat_number], unique: true, name: "index_messages_on_application_token_number_and_chat_number"
    add_index :messages, :chat_number, name: "fk_messages_to_chats_by_number"

    add_foreign_key :messages, :applications, column: "application_token", primary_key: "token", name: "fk_messages_to_applications"
    add_foreign_key :messages, :chats, column: "chat_number", primary_key: "number", name: "fk_messages_to_chats_by_number"
  end
end
