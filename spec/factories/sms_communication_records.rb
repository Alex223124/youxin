# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sms_communication_record, class: CommunicationRecord::Sms, parent: :base_communication_record do
  end
end
