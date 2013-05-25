FactoryGirl.define do
  factory :option, class: Field::Option do
    sequence(:value) { |n| "value-#{n}" }
  end
end
