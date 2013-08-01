class InputSerializer < ActiveModel::Serializer
  attributes :id,
             :default_value,
             :help_text,
             :identifier,
             :label,
             :position,
             :required,
             :type,
             :options

  def type
    object._type
  end
  def options
    object.options.as_json(only: [:default_selected, :value], methods: :id)
  end
  def default_value
    if has_options?
      object.options.select { |option| option.default_selected }.first.try(:value) if object.is_a?(Field::RadioButton)
    else
      object.default_value
    end
  end

  def has_options?
    object.is_a?(Field::RadioButton) || object.is_a?(Field::CheckBox)
  end
  def include_default_value?
    !object.is_a?(Field::CheckBox)
  end
  def include_options?
    has_options?
  end
end