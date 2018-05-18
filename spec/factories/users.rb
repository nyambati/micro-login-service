FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password "foobar"
    firstname "kali"
    lastname "linux"
  end
end
