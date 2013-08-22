# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :namespace do
    sequence(:name) { |n| "namespace-#{n}" }
  end
end
