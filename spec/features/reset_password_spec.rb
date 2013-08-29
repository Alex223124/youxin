# encoding: utf-8

require 'spec_helper'
require 'timeout'

feature "reset password" do
  let(:user) { create :user }

  before(:each) do
    stub_request(:any, 'http://api.smsbao.com/sms').to_return(body: '0')
  end

  background do
    clear_emails
  end

  scenario "succeeds with email" do
    visit new_user_password_path
    fill_in "user_reset_password_key", with: user.email
    find('.submit').click

    open_email(user.email)
    current_email.should have_content(user.name)

    current_email.click_link '修改密码'

    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    click_button '修改密码'
    expect(page).to have_content(user.name)
  end

  scenario "successfully with phone" do
    visit new_user_password_path
    fill_in "user_reset_password_key", with: user.phone
    find('.submit').click

    user.reload
    expect(page).to have_content(I18n.t('devise.passwords.send_sms'))
    fill_in 'user_reset_sms_token', with: user.reset_sms_token
    find('.submit').click

    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    find('.submit').click
    expect(page).to have_content(user.name)
  end

  scenario "should fail with incorrect phone" do
    user.send(:generate_reset_sms_token!)

    visit new_user_password_by_sms_path(phone: 'not_exist')
    expect(page).to have_content(I18n.t('errors.messages.not_found'))
  end
  scenario "should fail with incorrect reset_sms_token" do
    user.send(:generate_reset_sms_token!)

    visit new_user_password_by_sms_path(phone: user.phone)
    fill_in "user_reset_sms_token", with: "test"
    find('.submit').click
    expect(page).to have_content(I18n.t('errors.messages.not_found'))
  end
  scenario "should fail with expired reset_sms_token" do
    user.send(:generate_reset_sms_token!)
    user.reset_sms_sent_at = 1.hour.ago
    user.save

    visit new_user_password_by_sms_path(phone: user.phone)
    fill_in "user_reset_sms_token", with: user.reset_sms_token
    find('.submit').click

    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: user.password
    find('.submit').click
    expect(page).to have_content(I18n.t('errors.messages.expired'))
  end
  scenario "should generate new reset_sms_token if it is expired" do
    user.send(:generate_reset_sms_token!)
    user.reset_sms_sent_at = 1.hour.ago
    user.save
    reset_sms_token = user.reset_sms_token

    visit new_user_password_by_sms_path(phone: user.phone)
    click_on('重发验证码')
    user.reload
    user.reset_sms_token.should_not == reset_sms_token
  end
  scenario "should not generate new reset_sms_token if it isnt expired" do
    user.send(:generate_reset_sms_token!)
    reset_sms_token = user.reset_sms_token

    visit new_user_password_path(user: { reset_password_key: user.phone })
    user.reload
    user.reset_sms_token.should == reset_sms_token
  end

end