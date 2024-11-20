class Chat < ApplicationRecord

  belongs_to :application, foreign_key: :application_token, primary_key: :token
  has_many :messages, foreign_key: :chat_number, primary_key: :number


    validates :number, presence: true, uniqueness: { scope: :application_token  }, numericality: { only_integer: true, greater_than: 0 }
    validates :application_token, presence: true, allow_nil: false
    validates :messages_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :title, length: { maximum: 50 }, allow_nil: false
  

end