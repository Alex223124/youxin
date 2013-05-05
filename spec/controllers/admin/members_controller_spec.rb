require 'spec_helper'

describe Admin::MembersController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', id: 1
      response.should be_success
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      put 'update', id: 1
      response.should be_success
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      delete 'destroy', id: 1
      response.should be_success
    end
  end

end
