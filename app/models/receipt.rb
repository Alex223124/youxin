# encoding: utf-8

class Receipt
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :read, type: Boolean, default: false
  field :organization_ids, type: Array, default: []
  field :read_at, type: DateTime
  field :origin, type: Boolean, default: false
  field :author_id
  field :short_key, type: String

  before_save do
    self.author = self.post.author
  end
  before_create :ensure_short_key!

  belongs_to :user, inverse_of: :receipts
  belongs_to :author, class_name: 'User', inverse_of: :created_receipts
  belongs_to :post
  has_many :favorites, as: :favoriteable, dependent: :destroy, after_add: :mark_self_read
  has_many :sms_communication_records, class_name: 'CommunicationRecord::Sms'

  scope :read, where(read: true)
  scope :unread, where(read: false)
  default_scope desc(:_id)

  def organizations
    Organization.where(:id.in => self.organization_ids)
  end

  def read!
    self.read_at = Time.now
    self.read = true
    self.save
  end

  def ios_payload
    ios_payload_body = "#{self.post.title} #{self.post.body}"
    {
      alert: "【#{self.post.author.name}】:\n#{ios_payload_body[0...25]}...",
      custom: {
        type: :receipt,
        id: self.id.to_s,
      },
      badge: self.user.receipts.unread.count
    }
  end

  private
  def mark_self_read(favorite)
    favorite.favoriteable.read!
  end

  def ensure_short_key!
    begin
      self.short_key = generate_key
    end while Receipt.where(short_key: self.short_key).exists?
  end

  def generate_key
    SecureRandom.base64(7).tr('+/=', 'fAh')
  end

end
