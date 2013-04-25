require 'spec_helper'

feature "admin create users" do
  let(:admin) { create :admin }
  let(:user) { build :user }

  before(:each) do
    visit "/admin/users/new"
  end

  scenario "successfully" do
    fill_in "user_email", with: user.email
    fill_in "user_name", with: user.name
    fill_in "user_password", with: user.password
    fill_in "user_password_confirmation", with: user.password_confirmation

    click_button "Create User"
    expect(page).to have_content(user.name)
  end
end