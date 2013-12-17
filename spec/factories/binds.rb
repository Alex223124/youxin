FactoryGirl.define do
  factory :bind do
    sequence(:baidu_channel_id) { |n| "baidu_channel_id-#{n}" }
    sequence(:baidu_user_id) { |n| "baidu_user_id-#{n}" }
  end
end
