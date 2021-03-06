FactoryGirl.define do
  factory :feedback do
    sequence(:category) { |n| "category-#{n}" }
    sequence(:body) { |n| "body-#{n}" }
    sequence(:contact) { |n| "contact-#{n}" }
    sequence(:device) { |n| "device-#{n}" }
    sequence(:version_code) { |n| n }
    sequence(:version_name) { |n| "version #{n}" }
  end
end
