class Field::RadioButton < Field::Base
  attr_accessible :options_attributes

  validates :options, presence: true
  validate :ensure_option_selected

  embeds_many :options, class_name: 'Field::Option', inverse_of: :radio_button

  accepts_nested_attributes_for :options

  private
  def ensure_option_selected
    if self.options.where(default_selected: true).count > 1
      self.errors.add :options, :too_many_selected
      self.form.errors.add :radio_buttons, :too_many_options_selected
    end
  end
end