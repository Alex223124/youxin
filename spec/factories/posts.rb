# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    sequence(:title) { |n| "title-#{n}" }
    sequence(:body) { |n| "body-#{n}" }
    sequence(:body_html) { |n| "body_html-#{n}" }
    recipient_ids []
    organization_ids [1]
    attachment_ids []
  end
end
