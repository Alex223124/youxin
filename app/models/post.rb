class Post
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :title, type: String
  field :body, type: String
  field :body_html, type: String

  field :recipient_ids, type: Array, default: []
  field :organization_ids, type: Array, default: []
  field :organization_clan_ids, type: Array, default: []

  validates :author_id, presence: true
  validates :organization_ids, presence: true
  validates :body_html, presence: true

  attr_accessible :title, :body_html

  before_create do
    parse_body
  end
  after_create do
    create_receipts
  end

  belongs_to :author, class_name: 'User'
  has_many :receipts, dependent: :destroy do
    def read
      where(read: true, origin: false)
    end
    def unread
      where(read: false, origin: false)
    end
  end
  has_many :attachments, class_name: 'Attachment::Base', dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  def recipients
    User.where(:id.in => self.recipient_ids)
  end
  def organizations
    Organization.where(:id.in => self.organization_ids)
  end
  def organization_clans
    Organization.where(:id.in => self.organization_clan_ids)
  end

  private
  def parse_body
    self.body = Nokogiri::HTML(body_html).text
  end
  def create_receipts
    org_ids = self.organization_ids.uniq.sort_by do |organization_id|
                Organization.find(organization_id).offspring.size
              end.reverse
    self.organization_ids = []
    self.organization_clan_ids = []
    org_id = org_ids.shift
    until org_id.nil?
      organization = Organization.find(org_id)
      if organization.offspring.count != 0 && organization.offspring.map(&:id) - org_ids == []
        self.organization_clan_ids += [org_id]
        org_ids -= organization.offspring.map(&:id)
      else
        self.organization_ids += [org_id]
      end
      org_id = org_ids.shift
    end

    self.organizations.each do |organization|
      (organization.members - [self.author]).each do |member|
        receipt = self.receipts.first_or_create(user: member)
        receipt.organization_ids += [organization.id]
        receipt.save
        self.recipient_ids += [member.id]
      end
    end

    self.organization_clans.each do |organization_clans|
      members = ([organization_clans] + organization_clans.offspring).map(&:members).flatten.uniq - [self.author]
      members.each do |member|
        receipt = self.receipts.first_or_create(user: member)
        receipt.organization_ids += [organization_clans.id]
        receipt.save
        self.recipient_ids += [member.id]
      end
    end

    # create receipts for author
    self.receipts.create(user: self.author,
                         organization_ids: self.organization_ids + self.organization_clan_ids,
                         read: true,
                         origin: true)
  end
end
