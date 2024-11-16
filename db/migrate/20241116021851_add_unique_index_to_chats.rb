class AddUniqueIndexToChats < ActiveRecord::Migration[7.0]
  def change
    
    unless index_exists?(:chats, [:application_id, :number], unique: true, name: "index_chats_on_application_id_and_number")
      add_index :chats, [:application_id, :number], unique: true, name: "index_chats_on_application_id_and_number"
    end
  end
end
