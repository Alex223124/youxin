# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_mention, class: Notification::Mention, parent: :notification_base do
  end
end
