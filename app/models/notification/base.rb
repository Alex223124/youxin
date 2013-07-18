class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  store_in collection: :notifications

  field :read, type: Boolean, default: false

  validates :user_id, presence: true

  belongs_to :user

  scope :unread, where(read: false)
  default_scope desc(:_id)

  def read!
    self.read = true
    self.save
  end

end
