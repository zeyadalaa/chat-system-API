class RemoveIndexOnChatNumberFromChats < ActiveRecord::Migration[7.0]
  def change
    # Remove the index on chat_number in chats table if it exists
    if index_exists?(:chats, :chat_number)
      remove_index :chats, :chat_number
    end
  end
end
