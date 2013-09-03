# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scheduler_call, class: Scheduler::Call, parent: :base_scheduler do
  end
end
