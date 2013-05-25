class Field::TextArea < Field::Base
  field :default_value, type: String

  attr_accessible :default_value
end