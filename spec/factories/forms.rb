# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :form do
    sequence(:title) { |n| "title-#{n}" }
    author
  end
end
