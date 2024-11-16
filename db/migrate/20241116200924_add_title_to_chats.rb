class AddTitleToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :title, :string
  end
end
