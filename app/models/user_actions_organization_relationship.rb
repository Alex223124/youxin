class UserActionsOrganizationRelationship
  include Mongoid::Document

  field :user_id
  field :organization_id
  field :actions, type: Array, default: []

  belongs_to :user
  belongs_to :organization

  validates :user_id, presence: true
  validates :organization_id, presence: true
  validate :ensure_actions_inclusion

  after_save do
    # The same as self.organization.deauthorize(user)
    # Deauthorize user from the organization
    self.destroy if self.actions.blank?
  end

  def self.allowed(object, subject)
    return [] unless object.instance_of?(User)
    return [] unless subject.instance_of?(Organization)
    self.where(user_id: object.id, organization_id: subject.id).first.try(:actions)
  end

  private
  def ensure_actions_inclusion
    if self.actions.is_a?(Array)
      unless self.actions - Action.options_array == []
        self.errors.add :actions, :inclusion
      end
    else
      self.errors.add :actions, :format
    end
  end
end
