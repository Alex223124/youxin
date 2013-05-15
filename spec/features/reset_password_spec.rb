require 'spec_helper'

feature "reset password" do
  let(:user) { create :user }

  scenario "successfully" do
    pending 'need test, error on open_email'
    # visit '/users/password/new'

    # fill_in "user_email", with: user.email

    # click_button 'Send me reset password instructions'

    # open_email(user.email)
    # expect(page).to have_content(user.name)
  end
end