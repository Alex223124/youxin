class Receipt
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :read, type: Boolean, default: false
  field :organization_ids, type: Array, default: []
  field :read_at, type: DateTime
  field :origin, type: Boolean, default: false

  belongs_to :user
  belongs_to :post
  has_many :favorites, as: :favoriteable, dependent: :destroy

  delegate :author, to: :post, prefix: false
  scope :read, where(read: true)
  scope :unread, where(read: false)

  def organizations
    Organization.where(:id.in => self.organization_ids)
  end

  def read!
    self.read_at = Time.now
    self.save
  end

end
