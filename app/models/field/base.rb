class Field::Base
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :label, type: String
  field :help_text, type: String
  field :required, type: Boolean, default: false
  field :identifier, type: String
  field :position, type: Integer

  attr_accessible :label, :help_text, :required, :identifier, :position

  default_scope asc(:position)

  validates :form_id, presence: true

  store_in collection: :fields

  belongs_to :form

end