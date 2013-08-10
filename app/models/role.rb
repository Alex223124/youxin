class Role
  include Mongoid::Document
  field :name, type: String
  field :actions, type: Array, default: []

  has_many :user_role_organization_relationships, dependent: :destroy
end
