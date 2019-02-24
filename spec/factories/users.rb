FactoryBot.define do
  factory :user do
    name { Faker::Internet.username }
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :manager do
      manager { true }
    end
  end
end