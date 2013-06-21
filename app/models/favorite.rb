class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  validates :favoriteable_id, presence: true
  validates :favoriteable_type, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :favoriteable_id, scope: [:user_id, :favoriteable_type], message: 'favorited'

  belongs_to :favoriteable, polymorphic: true
  belongs_to :user

  default_scope desc(:_id)

end
