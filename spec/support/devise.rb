module DeviseControllerMacros

  def login_user(user = double('user'))
    if user.nil?
      request.env['warden'].stub(:authenticate!).
        and_throw(:warden, {:scope => :user})
      controller.stub :current_user => nil
    else
      request.env['warden'].stub :authenticate! => user
      controller.stub :current_user => user
    end
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
