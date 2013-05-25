# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sample_name = %w{adele john lucy fah david}.sample
  sequence(:name) { |n| "#{sample_name}#{n}" }
  sequence(:email) { |n| "#{sample_name}#{n}@y.x" }
  factory :user, aliases: [:applicant, :operator, :author] do
    name
    email
    password '12345678'
    password_confirmation '12345678'

    trait :confirmed do
      confirmed_at 1.hour.ago
    end

  end

  factory :admin, parent: :user do
    email Youxin.config.admin_emails.sample
  end
end
