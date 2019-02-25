FactoryBot.define do
  factory :issue do
    user { create(:user) }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
  end
end
