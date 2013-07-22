class UserRoleOrganizationRelationship
  include Mongoid::Document

  belongs_to :user
  belongs_to :role
  belongs_to :organization

  after_create do
    self.organization.authorize_cover_offspring(self.user, self.role.actions) if self.role.actions?
  end
end
