require 'spec_helper'

describe PasswordsController do
  it "to #new_by_sms" do
    get('/account/reset_password_by_sms/new').should route_to('passwords#new_by_sms')
  end
  it "to #edit_by_sms" do
    post('/account/reset_password_by_sms/edit').should route_to('passwords#edit_by_sms')
  end
end
