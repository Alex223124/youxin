# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_organization, class: Notification::Organization, parent: :notification_base do
  end
end
