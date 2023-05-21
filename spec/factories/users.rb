FactoryBot.define do
  factory :user do
    email { Faker::Internet.safe_email }
    username { Faker::Internet }
    password { Faker::Internet.password(min_length: 6) }
  end
end
