class Field::CheckBox < Field::Base
  attr_accessible :options_attributes

  embeds_many :options, class_name: 'Field::Option', inverse_of: :check_box

  accepts_nested_attributes_for :options

end