class Namespace
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  SUBDOMAIN_REGEXP = %r(\A(?=[a-z])[a-z0-9-]*(?<=[^-])\z)

  field :name, type: String
  field :subdomain, type: String
  field :subdomain_enabled, type: Boolean, default: false

  mount_uploader :logo, LogoUploader

  validates :subdomain, uniqueness: true, format: { with: SUBDOMAIN_REGEXP }, length: { maximum: 20 }, if: ->(namespace) { namespace.subdomain.present? or namespace.subdomain_enabled? }

  attr_accessible :name,
                  :logo, :logo_cache, :remove_logo

  has_many :organizations, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :roles, dependent: :destroy

  def self.allowed(object, subject)
    return [] unless object.instance_of?(User)
    return [] unless subject.instance_of?(Namespace)
    subject.organizations.where(parent_id: nil).each do |organization|
      return [:manage_namespace] if object.user_actions_organization_relationships.where(organization_id: organization.id).first.actions.include?(:edit_organization)
    end
    []
  end

end
