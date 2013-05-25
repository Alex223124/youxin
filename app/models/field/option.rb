class Field::Option
  include Mongoid::Document

  field :selected, type: Boolean, default: false
  field :value

  attr_accessible :selected, :value

  embedded_in :radio_button, class_name: 'Field::RadioButton'
  embedded_in :check_box, class_name: 'Field::RadioButton'
  validates :value, uniqueness: true

end