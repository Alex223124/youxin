class Organization
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :name, type: String
  field :parent_id
  field :member_ids, type: Array, default: []

  field :bio, type: String

  mount_uploader :avatar, AvatarUploader
  mount_uploader :header, HeaderUploader

  attr_accessible :name, :bio, :parent_id,
                  :avatar, :header

  belongs_to :parent, class_name: 'Organization'
  has_many :children, class_name: 'Organization', foreign_key: :parent_id
  has_many :user_organization_position_relationships, dependent: :destroy
  has_many :user_actions_organization_relationships, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :organization_notifications, class_name: 'Notification::Organization', dependent: :destroy
  has_many :user_role_organization_relationships, dependent: :destroy

  validates :name, presence: true
  validates :parent_id, presence: true, allow_nil: true
  validate :parent_exists, if: ->(organization) { organization.parent_id.present? }

  default_scope asc(:_id)

  after_destroy do
    self.members.each do |member|
      member.pull(:organization_ids, self.id)
    end
    self.pull_all(:member_ids, self.member_ids)
  end

  after_create do
    if self.parent
      self.parent.user_actions_organization_relationships.each do |relationship|
        authorization = relationship.clone
        authorization.organization_id = self.id
        authorization.save
      end
    end
  end

  def offspring
    organizations ||= self.children
    self.children.each do |child|
      organizations |= child.offspring
    end
    organizations
  end

  # Members
  def members
    User.where(:id.in => self.member_ids)
  end
  def push_member(user, position = nil)
    user = User.where(id: user).first unless user.is_a?(User)
    position = Position.where(id: position).first unless position.is_a?(Position)
    if user
      self.add_to_set(:member_ids, user.id)
      user.add_to_set(:organization_ids, self.id)
      relation = self.user_organization_position_relationships.where(user_id: user.id).first_or_create
      relation.update_attributes(position_id: position.id) if position
    end
  end
  def pull_member(user)
    user = User.where(id: user).first unless user.is_a?(User)
    if user
      self.pull(:member_ids, user.id)
      user.pull(:organization_ids, self.id)
      relation = self.user_organization_position_relationships.where(user_id: user.id).first
      relation.destroy if relation
    end
  end
  def push_members(users, position = nil)
    users.each do |user|
      self.push_member(user, position)
    end
  end
  def pull_members(users)
    users.each do |user|
      self.pull_member(user)
    end
  end
  alias_method :add_member, :push_member
  alias_method :add_members, :push_members
  alias_method :remove_member, :pull_member
  alias_method :remove_members, :pull_members
  # Members

  # Authorize
  # The new will overwrite the old actions
  def authorize(user, actions)
    user = User.find(user) unless user.is_a?(User)
    return unless user
    autorization = self.user_actions_organization_relationships.where(user_id: user.id).first_or_initialize
    autorization.actions = actions
    autorization.save
  end
  def authorize_cover_offspring(user, actions)
    (self.offspring + [self]).each do |organization|
      organization.authorize(user, actions)
    end
  end
  def authorized_users
    user_actions_organization_relationships.map(&:user)
  end
  def deauthorize(user)
    user = User.find(user) unless user.is_a?(User)
    return unless user
    self.user_actions_organization_relationships.where(user_id: user.id).try(:delete)
  end
  def deauthorize_cover_offspring(user)
    (self.offspring + [self]).each do |organization|
      organization.deauthorize(user)
    end
  end
  # Authorize

  private
  def parent_exists
    if Organization.where(id: self.parent_id).blank?
      self.errors.add :parent_id, "not_exist"
    end
  end
end
