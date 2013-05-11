module DeviseControllerMacros

  def login_user(user = nil)
    user ||= FactoryGirl.create(:user, :confirmed)
    sign_in user
    user
  end

end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include DeviseControllerMacros, type: :controller
end