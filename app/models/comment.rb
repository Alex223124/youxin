class Comment
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :body, type: String

  validates :body, presence: true
  validates :commentable_id, presence: true
  validates :commentable_type, presence: true
  validates :user_id, presence: true

  belongs_to :commentable, polymorphic: true
  belongs_to :user

end
