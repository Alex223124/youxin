class UserRoleOrganizationRelationship
  include Mongoid::Document

  belongs_to :user
  belongs_to :role
  belongs_to :organization

  validates_uniqueness_of :role_id, scope: [:user_id, :organization_id]

  after_save do
    self.organization.authorize_cover_offspring(self.user, self.role.actions)
  end
  before_destroy do
    self.organization.deauthorize_cover_offspring(self.user)
  end
end
