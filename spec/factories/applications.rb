# spec/factories/applications.rb
FactoryBot.define do
  factory :application do
    deviceName { Faker::Device.model_name[0...3] } 
  end
end
