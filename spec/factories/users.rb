# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sample_name = %w{adele john lucy fah david}.sample
  sequence(:name) { |n| "#{sample_name}#{n}" }
  sequence(:email) { |n| "#{sample_name}#{n}@y.x" }
  sequence(:phone) { |n| "#{18600000000 + n}" }
  factory :user, aliases: [:applicant, :operator, :author] do
    name
    email
    phone
    password '12345678'
    password_confirmation '12345678'
    namespace
  end

  factory :admin, parent: :user do
    email Youxin.config.admin_emails.sample
  end
end
