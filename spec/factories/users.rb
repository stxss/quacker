FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.username(specifier: 4..15, separators: ["_"]) }
    password { Faker::Internet.password(min_length: 6) }
  end
end
