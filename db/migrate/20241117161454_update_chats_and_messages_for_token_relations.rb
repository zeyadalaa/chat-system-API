class UpdateChatsAndMessagesForTokenRelations < ActiveRecord::Migration[7.0]
  def change
    # Remove the old unique index and application_id column
    if index_exists?(:chats, [:application_id, :number], name: "index_chats_on_application_id_and_number")
      remove_index :chats, name: "index_chats_on_application_id_and_number"
    end
    if index_exists?(:messages, [:chat_id, :number], name: "chat_id")
      remove_index :messages, name: "chat_id"
    end

    # Conditionally remove the application_id column if it exists
    if column_exists?(:chats, :application_id)
      remove_column :chats, :application_id, :integer
    end
    if column_exists?(:messages, :application_id)
      remove_column :messages, :application_id, :integer
    end

    # Create a unique index on [application_token, number]
    add_index :chats, [:application_token, :number], unique: true, name: "index_chats_on_application_token_and_number"
    add_index :messages, [:application_token, :number], unique: true, name: "index_messages_on_application_token_and_number"

    # Add foreign key constraints for application_token to both tables
    add_foreign_key :chats, :applications, column: :application_token, primary_key: :token, name: "fk_chats_to_applications"

    add_foreign_key :messages, :chats, column: :chat_id, primary_key: :id, name: "fk_messages_to_chats"
    add_foreign_key :messages, :applications, column: :application_token, primary_key: :token, name: "fk_messages_to_applications"

  end
end
