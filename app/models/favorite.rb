class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  validates :favoriteable_id, presence: true
  validates :favoriteable_type, presence: true
  validates :user_id, presence: true

  belongs_to :favoriteable, polymorphic: true
  belongs_to :user
end
