require 'spec_helper'

describe "Admin" do
  context "Users" do
    describe "GET /admin/users" do
      it "works" do
        get admin_users_path
        response.status.should be(200)
      end
    end

    describe "GET /admin/users/new" do
      it "works" do
        get new_admin_user_path
        response.status.should be(200)
      end    
    end
  end
end
