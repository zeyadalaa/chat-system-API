class RemoveIndexOnNumberFromChats < ActiveRecord::Migration[7.0]
  def change
    # Step 1: Remove the foreign key constraint on chat_number if it exists
    if foreign_key_exists?(:messages, :chats, column: :chat_number)
      remove_foreign_key :messages, :chats, column: :chat_number
    end

    # Step 2: Remove the index on number in chats table if it exists
    if index_exists?(:chats, :number)
      remove_index :chats, :number
    end
    unless index_exists?(:chats, :number)
      add_index :chats, :number, name: "index_chats_on_number"
    end

    # Step 4: Re-add the foreign key constraint from messages.chat_number to chats.number
    add_foreign_key :messages, :chats, column: :chat_number, primary_key: :number, name: "fk_messages_to_chats_by_number"

  end
end
