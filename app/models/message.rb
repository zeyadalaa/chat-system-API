class Message < ApplicationRecord
  belongs_to :chat, foreign_key: :chat_number, primary_key: :number
  belongs_to :application, foreign_key: :application_token, primary_key: :token
  

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: [:application_token, :chat_number] }
  validates :chat_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :application_token, presence: true
  validates :content, presence: true, length: { maximum: 255 }, allow_nil: false

end