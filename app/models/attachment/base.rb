class Attachment::Base
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  store_in collection: :attachments

  validates :user_id, presence: true

  belongs_to :user
  belongs_to :post

  default_scope desc(:_id)

  def self.allowed(object, subject)
    return [] unless object.instance_of?(User)
    return [] unless subject.instance_of?(Attachment::Base) || subject.instance_of?(Attachment::File) || subject.instance_of?(Attachment::Image)
    abilities = []
    if subject.post
      abilities |= [:download] if object.receipts.where(post_id: subject.post.id).exists?
    end
    abilities |= [:download, :manage] if subject.user_id == object.id
    abilities
  end

end