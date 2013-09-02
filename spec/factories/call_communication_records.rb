# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_communication_record, class: CommunicationRecord::Call, parent: :base_communication_record do
  end
end
