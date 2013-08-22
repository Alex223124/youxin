class Namespace
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields
  field :name, type: String, default: ""

  has_many :organizations, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :roles, dependent: :destroy
end
