FactoryGirl.define do
  factory :feedback do
    sequence(:category) { |n| "category-#{n}" }
    sequence(:body) { |n| "body-#{n}" }
    sequence(:contact) { |n| "contact-#{n}" }
    sequence(:devise) { |n| "devise-#{n}" }
    sequence(:version_code) { |n| n }
    version_name "version #{version_code}"
  end
end
