require 'spec_helper'

feature "uesr sign in" do
  before(:each) do
    visit '/users/sign_in'
  end
  scenario "successfully" do
    user_attrs = attributes_for(:user)
    User.create(user_attrs)
    fill_in "user_email", with: user_attrs[:email]
    fill_in "user_password", with: user_attrs[:password]

    click_button "Sign in"
    expect(page).to have_content(user_attrs[:name])
  end
end