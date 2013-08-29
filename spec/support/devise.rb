module DeviseControllerMacros

  def login_user(user = nil)
    user ||= FactoryGirl.create(:user)
    sign_in user
    user
  end

end

module DeviseFeatureMacros
  def sign_in(user = nil)
    user ||= FactoryGirl.create(:user)

    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Sign in'
    user
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include DeviseControllerMacros, type: :controller
  config.include DeviseFeatureMacros, type: :feature
end

# disable async for test email
Devise::Async.enabled = false
