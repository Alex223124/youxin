class Attachment::Base
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  store_in collection: :attachments

  validates :user_id, presence: true

  belongs_to :user
  belongs_to :post

end