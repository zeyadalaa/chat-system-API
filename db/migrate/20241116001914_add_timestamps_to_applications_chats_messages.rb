class AddTimestampsToApplicationsChatsMessages < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :applications, null: true unless column_exists?(:applications, :created_at)
    add_timestamps :chats, null: true unless column_exists?(:chats, :created_at)
    add_timestamps :messages, null: true unless column_exists?(:messages, :created_at)
  end
end
