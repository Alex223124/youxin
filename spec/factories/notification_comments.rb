# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_comment, class: Notification::Comment, parent: :notification_base do
  end
end
