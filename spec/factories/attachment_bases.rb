FactoryGirl.define do
  factory :attachment_base, class: Attachment::Base do
    user
  end
end
