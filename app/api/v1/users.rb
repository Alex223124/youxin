class Users < Grape::API
  before { authenticate! }

  resource :user do
    get do
      present current_user, with: Youxin::Entities::User
    end

    get 'authorized_organizations' do
      actions = attributes_for_keys([:actions])[:actions]
      if actions
        actions = actions.map(&:to_sym)
        authorized_organizations = []
        relationships = current_user.user_actions_organization_relationships
        relationships.each do |relationship|
          authorized_organizations << relationship.organization if actions - relationship.actions == []
        end
      else
        authorized_organizations = current_user.authorized_organizations
      end

      present authorized_organizations, with: Youxin::Entities::OrganizationBasic
    end
  end
end