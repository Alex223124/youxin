class Organization
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :name, type: String
  field :parent_id
  field :member_ids, type: Array, default: []

  belongs_to :parent, class_name: 'Organization'
  has_many :children, class_name: 'Organization', foreign_key: :parent_id
  has_many :user_organization_position_relationships, dependent: :destroy

  validates :name, presence: true
  validates :parent_id, presence: true, allow_nil: true
  validate :parent_exists, if: ->(organization) { organization.parent_id.present? }

  after_destroy do
    self.members.each do |member|
      member.pull(:organization_ids, self.id)
    end
    self.pull_all(:member_ids, self.member_ids)
  end

  def parent_exists
    if Organization.where(id: self.parent_id).blank?
      self.errors.add :parent_id, "not_exist"
    end
  end
  
  # Members
  def members
    User.where(:id.in => self.member_ids)
  end
  def push_member(user, position = nil)
    user = User.where(id: user).first unless user.is_a?(User)
    position = Position.where(id: position).first unless position.is_a?(Position)
    if user
      self.push(:member_ids, user.id)
      user.push(:organization_ids, self.id)
      self.user_organization_position_relationships.create(user_id: user.id, position_id: position.try(:id))
    end
  end
  def pull_member(user)
    user = User.where(id: user).first unless user.is_a?(User)
    if user
      self.pull(:member_ids, user.id)
      user.pull(:organization_ids, self.id)
      self.user_organization_position_relationships.where(user_id: user.id).delete
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

end
