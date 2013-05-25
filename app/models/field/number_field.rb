class Field::NumberField < Field::Base
  field :default_value, type: Float

  attr_accessible :default_value
end