class UpdateChatsAndMessagesForTokenAndChatNumberRelations < ActiveRecord::Migration[7.0]
  def change
    # Add index on application_token in chats if it doesn't exist
    unless index_exists?(:chats, :application_token)
      add_index :chats, :application_token, name: "index_chats_on_application_token"
    end

    # Remove the foreign key constraint on chat_id in messages if it exists
    if foreign_key_exists?(:messages, :chats, column: :chat_id)
      remove_foreign_key :messages, :chats, column: :chat_id
    end

    # Remove the index on chat_id in messages if it exists
    if index_exists?(:messages, :chat_id)
      remove_index :messages, name: "chat_id_idx"
    end

    # Remove the chat_id column from messages table if it exists
    if column_exists?(:messages, :chat_id)
      remove_column :messages, :chat_id
    end

    # Add the new chat_number column to messages table if it doesn't already exist
    unless column_exists?(:messages, :chat_number)
      add_column :messages, :chat_number, :integer, null: false
    end

    # Add an index on chat_number in messages to ensure the foreign key can be created
    unless index_exists?(:messages, :chat_number)
      add_index :messages, :chat_number, name: "index_messages_on_chat_number"
    end
    
    # Ensure there is an index on chats.number before adding the foreign key
    unless index_exists?(:chats, :number)
      add_index :chats, :number, name: "index_chats_on_number"
    end

    # Add a foreign key from messages.chat_number to chats.number
    add_foreign_key :messages, :chats, column: :chat_number, primary_key: :number, name: "fk_messages_to_chats_by_number"

    # Remove the old unique index in messages (application_token, number) if it exists
    if index_exists?(:messages, "index_messages_on_application_token_and_number")
      remove_index :messages, name: "index_messages_on_application_token_and_number"
    end

    # Add the new unique index on (application_token, number, chat_number) in messages
    add_index :messages, [:application_token, :number, :chat_number], name: "index_messages_on_application_token_number_and_chat_number", unique: true
  end
end
