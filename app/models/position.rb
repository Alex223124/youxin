class Position
  include Mongoid::Document
  field :name, type: String

  belongs_to :namespace

  validates :namespace_id, presence: true
end
