class Chat < ApplicationRecord

    belongs_to :application
    has_many :messages


    validates :number, presence: true, uniqueness: { scope: :application_id }, numericality: { only_integer: true, greater_than: 0 }
    validates :application_token, presence: true, allow_nil: false
    validates :messages_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :title, length: { maximum: 255 }, allow_nil: false
  

  end