FactoryBot.define do
  factory :role do
    name ""
    domain { Faker::Internet.domain_name }
  end
end
