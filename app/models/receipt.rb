class Receipt
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :read, type: Boolean, default: false
  field :organization_ids, type: Array, default: []
  field :read_at, type: DateTime
  field :origin, type: Boolean, default: false
  field :author_id

  before_save do
    self.author = self.post.author
  end

  belongs_to :user, inverse_of: :receipts
  belongs_to :author, class_name: 'User', inverse_of: :created_receipts
  belongs_to :post
  has_many :favorites, as: :favoriteable, dependent: :destroy

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

end
