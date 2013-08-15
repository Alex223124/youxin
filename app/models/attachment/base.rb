class Attachment::Base
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  store_in collection: :attachments

  validates :user_id, presence: true

  belongs_to :user
  belongs_to :post

  default_scope desc(:_id)

  def self.allowed(object, subject)
    return [] unless object.is_a?(User)
    return [] unless subject.is_a?(Attachment::Base)
    abilities = []
    if subject.post
      abilities |= [:download] if object.receipts.where(post_id: subject.post.id).exists?
    end
    abilities |= [:download, :manage] if subject.user_id == object.id
    abilities
  end

end