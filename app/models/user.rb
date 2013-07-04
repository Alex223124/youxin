class User
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  ## Token authenticatable
  field :authentication_token, type: String

  field :name, type: String
  field :organization_ids, type: Array, default: []
  field :receipt_organization_ids, type: Array, default: []
  field :receipt_user_ids, type: Array, default: []

  validates :name, presence: true

  mount_uploader :avatar, AvatarUploader

  attr_accessible :name, :email, :password, :password_confirmation, :avatar, :avatar_cache, :remove_avatar

  has_many :user_organization_position_relationships, dependent: :destroy
  has_many :user_actions_organization_relationships, dependent: :destroy
  has_many :applications, dependent: :destroy, foreign_key: 'applicant_id'
  has_many :treated_applications, dependent: :destroy, class_name: 'Application', foreign_key: 'operator_id'
  has_many :posts, dependent: :destroy, inverse_of: :author, foreign_key: :author_id
  has_many :receipts, dependent: :destroy, inverse_of: :user do
    def from_user(user)
      user = User.find(user) unless user.is_a?(User)
      where(author_id: user.id)
    end
    def from_organization(organization)
      organization = Organization.find(organization) unless organization.is_a?(Organization)
      where(:organization_ids => organization.id)
    end
  end
  has_many :created_receipts, dependent: :destroy, foreign_key: 'author_id', class_name: 'Receipt', inverse_of: :author
  has_many :attachments, class_name: 'Attachment::Base', dependent: :destroy
  has_many :forms, dependent: :destroy, inverse_of: :author, foreign_key: :author_id
  has_many :collections, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, dependent: :destroy do
    def receipts
      where(favoriteable_type: 'Receipt')
    end
  end
  has_many :file_attachments, class_name: 'Attachment::File', dependent: :destroy
  has_many :image_attachments, class_name: 'Attachment::Image', dependent: :destroy
  has_many :notifications, class_name: 'Notification::Base', dependent: :destroy
  has_many :comment_notifications, class_name: 'Notification::Comment', dependent: :destroy
  has_many :organization_notifications, class_name: 'Notification::Organization', dependent: :destroy

  before_save :ensure_authentication_token!
  alias_attribute :private_token, :authentication_token

  after_destroy do
    organizations.each do |organization|
      organization.pull(:member_ids, self.id)
    end
    self.pull_all(:organization_ids, self.organization_ids)
  end

  # 处理没有提供密码时修改个人信息
  def update_with_password(params={})
    if !params[:current_password].blank? or !params[:password].blank? or !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      self.update_without_password(params)
    end
  end

  # Organizations
  def organizations
    Organization.where(:id.in => self.organization_ids)
  end
  def position_in_organization(organization)
    user_organization_position_relationships.where(organization_id: organization.id).first.try(:position)
  end
  def human_position_in_organization(organization)
    position_in_organization(organization).try(:name)
  end
  # Organization

  # Authorization
  def authorized_organizations(actions = nil)
    if actions
      actions.map(&:to_sym)
      authorized_orgs = []
      self.user_actions_organization_relationships.each do |relationship|
        authorized_orgs << relationship.organization if actions - relationship.actions == []
      end
      authorized_orgs
    else
      self.user_actions_organization_relationships.map(&:organization)
    end
  end

  # Apply for organization
  def apply_for_organization(organization)
    organization = Organization.find(organization) unless organization.is_a?(Organization)
    return false unless organization
    self.applications.create(organization_id: organization.id)
  end
  def applied_for_organization?(organization)
    organization = Organization.find(organization) unless organization.is_a?(Organization)
    return false unless organization
    self.applications.where(organization_id: organization.id).exists?
  end
  def accepted_by_organization?(organization)
    organization = Organization.find(organization) unless organization.is_a?(Organization)
    return false unless organization
    return false unless applied_for_organization?(organization)
    self.applications.where(organization_id: organization.id, state: :accepted).exists?
  end
  def operate_application(application, result)
    application = Application.find(application) unless application.is_a?(Application)
    return false unless application
    self.treated_applications << application
    case result.to_sym
    when :accepted
      application.accept!
    when :rejected
      application.reject!
    else
      false
    end
  end
  # Apply for organization

  # Receipt
  def receipt_organizations
    Organization.where(:id.in => self.receipt_organization_ids)
  end
  def receipt_users
    User.where(:id.in => self.receipt_user_ids)
  end
  # Receipt
end
