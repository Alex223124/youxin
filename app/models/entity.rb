class Entity
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :key, type: String
  field :value

  attr_accessible :key, :value

  validates :key, presence: true, uniqueness: true
  validate do
    form = self.collection.form
    input = form.inputs.where(identifier: self.key).first
    if input
      if self.value.present?
        case input.class
        when Field::RadioButton
          option_id = self.value
          self.collection.errors.add :entities, "#{self.key}_not_found_radio_button_option" unless input.options.where(id: option_id).exists?
        when Field::CheckBox
          self.collection.errors.add :entities, "#{self.key}_invalid_check_box_option" unless self.value.is_a?(Array)
          if self.value.is_a?(Array)
            self.collection.errors.add :entities, "#{self.key}_not_found_check_box_option" unless (self.value.map(&:to_s) - input.options.map(&:id).map(&:to_s)).blank?
          end
        when Field::NumberField
          unless self.value.to_s =~ /\A[+-]?\d+(\.\d+)?\Z/
            self.collection.errors.add :entities, "#{self.key}_invalid_number"
          end
        end
      else
        self.collection.errors.add :entities, "#{self.key}_required" if input.required?
      end
    else
      self.collection.errors.add :entities, "not_found_input"
    end

  end

  embedded_in :collection

  # TODO: need_test
  def get_value
    form = self.collection.form
    input = form.inputs.where(identifier: self.key).first
    case input.class
    when Field::TextField, Field::TextArea, Field::NumberField
      self.value
    when Field::RadioButton
      (input.options.where(id: self.value).first || input.options.where(default_selected: true).first).try(:value)
    when Field::CheckBox
      (input.options.where(:id.in => self.value) || input.options.where(default_selected: true)).map(&:value).join(', ')
    end
  end
end
