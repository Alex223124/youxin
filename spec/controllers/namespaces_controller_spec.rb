require 'spec_helper'

describe NamespacesController do
  include JsonParser

  let(:namespace) { create :namespace }
  let(:admin) { create :user, namespace: namespace }

  describe "GET show" do
    before(:each) do
      login_user admin
    end
    it 'should return the namespace' do
      get :show
      json_response['namespace'].should_not be_blank
    end
  end
  describe 'PUT update' do
    before(:each) do
      @parent = create :organization, namespace: namespace
      actions_organization = Action.options_array_for(:organization)
      @parent.authorize_cover_offspring(admin, actions_organization)
    end
    it "should fail if not authorized" do
      attrs = {
        name: 'new-name'
      }
      expect do
        put :update, namespace: attrs
        namespace.reload
      end.not_to change { namespace.name }
    end
    context 'name' do
      before(:each) do
        login_user admin
      end
      it 'should update the name' do
        attrs = {
          name: 'new-name'
        }
        expect do
          put :update, namespace: attrs
          namespace.reload
        end.to change { namespace.name }
      end
    end
    context 'logo' do
      before(:each) do
        login_user admin
      end
      it 'should update logo' do
        logo_path = Rails.root.join("spec/factories/images/logo.png")
        attrs = {
          logo: Rack::Test::UploadedFile.new(logo_path)
        }
        expect do
          put :update, namespace: attrs
          namespace.reload
        end.to change { namespace.logo.file }
      end
    end
  end
end
