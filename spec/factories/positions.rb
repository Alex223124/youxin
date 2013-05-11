# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :position do
    sequence(:name) { |n| "position-#{n}" }
  end
end
