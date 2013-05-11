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
end
