class AddUniqueIndexToMessages < ActiveRecord::Migration[7.0]
  def change


    if foreign_key_exists?(:messages, column: :application_token)
      remove_foreign_key :messages, column: :application_token
    end

    if index_exists?(:messages, [:application_token, :number, :chat_number])
      remove_index :messages, column: [:application_token, :number, :chat_number]
    end

    unless index_exists?(:messages, [:application_token, :number, :chat_number], name: "index_messages_on_application_token_number_and_chat_number")
      add_index :messages, [:application_token, :number, :chat_number], unique: true, name: "index_messages_on_application_token_number_and_chat_number"
    end
    
    add_foreign_key :messages, :applications, column: :application_token, primary_key: :token, name: "fk_messages_to_applications"

  end
end
