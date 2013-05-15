require 'spec_helper'

feature 'admin create users' do
  let(:user) { create :user }

  before(:each) do
    sign_in(user)
    visit '/users/edit'
  end

  scenario 'update user profile' do
    modify_name = 'modify-name'

    within '#edit_user' do
      fill_in 'user_name', with: modify_name
      click_on 'Update'
    end

    expect(page).to have_content(modify_name)
  end
  scenario 'raise error update user password without rurrent_user' do
    modify_password = 656516164165
    within '#edit_password' do
      fill_in 'user_password_confirmation', with: modify_password
      fill_in 'user_password', with: modify_password
      click_on 'Update'
    end
    expect(page).to have_content('problems')
  end 
  scenario 'update user password' do
    modify_password = 656516164165
    within '#edit_password' do
      fill_in 'user_password_confirmation', with: modify_password
      fill_in 'user_password', with: modify_password
      fill_in 'password', with: attributes_for(:user)[:password]
      click_on 'Update'
    end
    expect(page).to have_content('updated')
  end 
end