class CommunicationRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String

  validate :receipt_id, presence: true

  belongs_to :user
  belongs_to :receipt

  before_create do
    return false unless self.receipt
    self.user = self.receipt.author
  end
end
