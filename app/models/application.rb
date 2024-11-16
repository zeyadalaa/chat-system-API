class Application < ApplicationRecord
    has_many :chats
    has_many :messages

    before_validation :generate_token, on: :create

    validates :token, presence: true, uniqueness: true, allow_nil: false
    validates :deviceName, presence: true, length: { minimum: 3, maximum: 50 }
    validates :password, presence: true, length: { minimum: 6 }
    
  
    private
  
    def generate_token
        #token will be generated if one does not already exist
      self.token ||= SecureRandom.uuid
    end
end
  