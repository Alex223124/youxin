class Organization
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :name, type: String
  field :parent_id

  belongs_to :parent, class_name: 'Organization'
  has_many :children, class_name: 'Organization', foreign_key: :parent_id

  validates :name, presence: true
  validates :parent_id, presence: true, allow_nil: true
end
