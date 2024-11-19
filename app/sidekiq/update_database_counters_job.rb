class UpdateDatabaseCountersJob < ApplicationJob
  queue_as :default
  
  def perform(*args)
    # Handle chat counts
    update_chat_counts

    # Handle message counts
    update_message_counts
  end

  private

  def update_chat_counts
    chat_keys = $redis.keys('*:chat_count')

    chat_keys.each do |key|
      application_token = key.split(':').first

      chat_count = $redis.get(key).to_i

      Application.where(token: application_token).update_all(chats_count: chat_count)
    end
  end

  def update_message_counts
    message_keys = $redis.keys('*:message_count')

    message_keys.each do |key|
      parts = key.split(':')
      application_token = parts[0]
      chat_number = parts[2]

      message_count = $redis.get(key).to_i

      Chat.where(application_token: application_token, number: chat_number).update_all(messages_count: message_count)
    end
  end
end
