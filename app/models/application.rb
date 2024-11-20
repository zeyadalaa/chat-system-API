class Application < ApplicationRecord
  has_many :chats, foreign_key: :application_token, primary_key: :token
  has_many :messages, foreign_key: :application_token, primary_key: :token

    before_validation :generate_token, on: :create

    validates :token, presence: true, uniqueness: true, allow_nil: false
    validates :deviceName, presence: true, length: { minimum: 3, maximum: 50 }
    
  
    private
  
    def generate_token
        #token will be generated if one does not already exist
      self.token ||= SecureRandom.uuid
    end
end
  