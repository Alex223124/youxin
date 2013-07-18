# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:body) { |n| "body-#{n}" }
  factory :message do
    body
  end
end
