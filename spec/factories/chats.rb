# spec/factories/chats.rb
FactoryBot.define do
  factory :chat do
    title { Faker::Lorem.words(number: 3).join(' ')} 
  end
end
