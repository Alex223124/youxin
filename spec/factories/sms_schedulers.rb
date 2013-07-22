# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sms_scheduler, class: Scheduler::Sms, parent: :base_scheduler do
  end
end
