module DeviseControllerMacros

  def login_user(user = nil)
    user ||= FactoryGirl.create(:user, :confirmed)
    user.confirm!
    sign_in user
    user
  end

end
