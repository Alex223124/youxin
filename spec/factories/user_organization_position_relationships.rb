# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_organization_position_relationship do
    user
    organization
    position
  end
end
