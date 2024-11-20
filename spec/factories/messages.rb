# spec/factories/messages.rb
FactoryBot.define do
  factory :message do
    content { Faker::Lorem.sentence(word_count: rand(1..15)) }  # Generates a sentence with a random number of words, from 1 to 25.


    trait :with_dynamic_content do
      content { Faker::Lorem.sentence }  # Example dynamic content
    end
  end
end
