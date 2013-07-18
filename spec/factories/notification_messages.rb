# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_message, class: Notification::Message, parent: :notification_base do
  end
end
