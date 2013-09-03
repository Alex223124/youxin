class Post
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  include ActionView::Helpers::TextHelper

  field :title, type: String
  field :body, type: String
  field :body_html, type: String

  field :recipient_ids, type: Array, default: []
  field :organization_ids, type: Array, default: []
  field :organization_clan_ids, type: Array, default: []

  validates :author_id, presence: true
  validates :organization_ids, presence: true
  validates :title, length: { maximum: 20 }
  validates :body_html, presence: true

  attr_accessible :title, :body, :body_html, :organization_ids,
                  :author_id, :organization_clan_ids
  attr_accessor :attachment_ids
  before_create do
    parse_body
  end
  after_create do
    create_receipts
    send_notifications
  end

  belongs_to :author, class_name: 'User'
  has_many :receipts, dependent: :destroy do
    def all
      where(origin: false)
    end
    def read
      where(read: true, origin: false)
    end
    def unread
      where(read: false, origin: false)
    end
  end
  has_many :attachments, class_name: 'Attachment::Base', dependent: :destroy
  has_many :forms, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy, after_add: :mark_receipt_read
  has_many :schedulers, class_name: 'Scheduler::Base', dependent: :destroy
  has_many :sms_schedulers, class_name: 'Scheduler::Sms', dependent: :destroy
  has_many :call_schedulers, class_name: 'Scheduler::Call', dependent: :destroy

  default_scope desc(:_id)

  def self.allowed(object, subject)
    return [] unless object.instance_of?(User)
    return [] unless subject.instance_of?(Post)
    abilities = []
    abilities |= [:read] if subject.receipts.map(&:user_id).include?(object.id)
    abilities |= [:read, :manage] if subject.author_id == object.id
    abilities
  end

  def recipients
    self.receipts.all.map(&:user)
    # User.where(:id.in => self.recipient_ids)
  end
  def organizations
    Organization.where(:id.in => self.organization_ids)
  end
  def organization_clans
    Organization.where(:id.in => self.organization_clan_ids)
  end

  def faye_payload
    self.as_json(only: [:created_at, :body, :title], methods: [:id], root: true,
                  include: {
                    author: { only: [:name], methods: [:id, :avatar_url] }
                  })
  end

  private
  def parse_body
    self.body = truncate(Nokogiri::HTML(body_html).text, length: 50)
  end
  def create_receipts
    org_ids = self.organization_ids.uniq.sort_by do |organization_id|
                Organization.find(organization_id).offspring.size
              end.reverse
    org_ids = org_ids.map { |org_id| Moped::BSON::ObjectId.from_string(org_id) }
    self.organization_ids = []
    self.organization_clan_ids = []
    org_id = org_ids.shift
    until org_id.nil?
      organization = Organization.find(org_id)
      if organization.offspring.count != 0 && organization.offspring.map(&:id) - org_ids == []
        self.organization_clan_ids |= [org_id]
        org_ids -= organization.offspring.map(&:id)
      else
        self.organization_ids |= [org_id]
      end
      org_id = org_ids.shift
    end

    self.organizations.each do |organization|
      (organization.members - [self.author]).each do |member|
        receipt = self.receipts.where(user: member).first_or_create
        receipt.organization_ids |= [organization.id]
        receipt.save
        member.add_to_set(:receipt_organization_ids, organization.id)
        member.add_to_set(:receipt_user_ids, self.author_id)
        self.recipient_ids |= [member.id]
      end
    end

    self.organization_clans.each do |organization_clan|
      members = ([organization_clan] + organization_clan.offspring).map(&:members).flatten.uniq - [self.author]
      members.each do |member|
        receipt = self.receipts.where(user: member).first_or_create
        receipt.organization_ids |= [organization_clan.id]
        receipt.save
        member.add_to_set(:receipt_organization_ids, organization_clan.id)
        member.add_to_set(:receipt_user_ids, self.author_id)
        self.recipient_ids |= [member.id]
      end
    end

    # create receipts for author
    self.receipts.create(user: self.author,
                         organization_ids: self.organization_ids + self.organization_clan_ids,
                         read: true,
                         origin: true)
    self.save
  end

  def send_notifications
    Notification::Notifier.publish_post_to_ios_device_async(self.id)
    Notification::Notifier.publish_post_to_faye_client_async(self.id)
  end

  def mark_receipt_read(comment)
    comment.user.receipts.where(post_id: self.id).map(&:read!)
  end

end
