FactoryBot.define do
  factory :tweet do
    body { Faker::Hipster.paragraphs(number: 2).join }
  end
end
