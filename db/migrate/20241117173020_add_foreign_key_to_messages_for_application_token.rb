class AddForeignKeyToMessagesForApplicationToken < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key "messages", "applications", column: "application_token", primary_key: "token", name: "fk_messages_to_applications"

  end
end
