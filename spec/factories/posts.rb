FactoryBot.define do
  factory :post do
    body { Faker::Hipster.paragraphs(number: 2).join }
  end
end
