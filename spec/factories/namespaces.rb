# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :namespace do
    sequence(:name) { |n| "namespace-#{n}" }
    sequence(:subdomain) { |n| "subdomain-#{n}" }
    subdomain_enabled false
  end
end
