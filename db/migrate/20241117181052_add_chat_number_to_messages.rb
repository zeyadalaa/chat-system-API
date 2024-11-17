class AddChatNumberToMessages < ActiveRecord::Migration[7.0]
  def change
    # Add the chat_number column to messages
    add_column :messages, :chat_number, :integer, null: false

    # Add the foreign key constraint to chat_number
    add_foreign_key :messages, :chats, column: :chat_number, primary_key: :number, name: 'fk_messages_to_chats_by_number'
  end
end
