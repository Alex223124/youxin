class UserOrganizationPositionRelationship
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :user_id
  field :organization_id
  field :position_id

  validates :user_id, presence: true
  validates :organization_id, presence: true
  validates_uniqueness_of :user_id, scope: [:organization_id], message: 'duplicate'

  belongs_to :user
  belongs_to :organization
  belongs_to :position

  after_create do
    self.user.organization_notifications._in.create(organization_id: self.organization_id)
    add_tag_to_user
  end
  after_destroy do
    self.user.organization_notifications._out.create(organization_id: self.organization_id)
    remove_tag_to_user
  end

  private
  def add_tag_to_user
    self.user.add_tag(self.organization.tag)
  end
  def remove_tag_to_user
    self.user.remove_tag(self.organization.tag)
  end
end
