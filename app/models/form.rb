# encoding: utf-8

class Form
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :title, type: String

  attr_accessible :title, :post_id, :text_fields_attributes, :text_areas_attributes,
                  :radio_buttons_attributes, :check_boxes_attributes, :number_fields_attributes

  validates :title, presence: true

  belongs_to :author, class_name: 'User'
  belongs_to :post
  has_many :inputs, class_name: 'Field::Base', dependent: :destroy, order: 'inputs.position asc'
  has_many :text_fields, class_name: 'Field::TextField', dependent: :destroy
  has_many :text_areas, class_name: 'Field::TextArea', dependent: :destroy
  has_many :radio_buttons, class_name: 'Field::RadioButton', dependent: :destroy
  has_many :check_boxes, class_name: 'Field::CheckBox', dependent: :destroy
  has_many :number_fields, class_name: 'Field::NumberField', dependent: :destroy
  has_many :collections, dependent: :destroy

  accepts_nested_attributes_for :text_fields
  accepts_nested_attributes_for :text_areas
  accepts_nested_attributes_for :radio_buttons
  accepts_nested_attributes_for :check_boxes
  accepts_nested_attributes_for :number_fields

  class << self
    def clean_attributes_with_inputs(attrs = {})
      inputs = attrs.delete(:inputs)
      field_num = 0
      attrs[:text_fields_attributes] = {}
      attrs[:text_areas_attributes] = {}
      attrs[:radio_buttons_attributes] = {}
      attrs[:check_boxes_attributes] = {}
      attrs[:number_fields_attributes] = {}
      inputs.each do |input|
        field_num += 1
        input[:identifier] = "field_#{ field_num }"
        input[:position] = field_num
        case input[:_type]
        when "Field::TextField"
          input.delete(:_type)

          attrs[:text_fields_attributes][field_num] = input
        when "Field::TextArea"
          input.delete(:_type)

          attrs[:text_areas_attributes][field_num] = input
        when "Field::RadioButton"
          input.delete(:_type)

          input[:options_attributes] = {}
          options = input.delete(:options)
          options.each_with_index do |option, index|
            option.delete(:_type)
            input[:options_attributes][index] = option
          end
          attrs[:radio_buttons_attributes][field_num] = input
        when "Field::CheckBox"
          input.delete(:_type)

          input[:options_attributes] = {}
          options = input.delete(:options)
          options.each_with_index do |option, index|
            option.delete(:_type)
            input[:options_attributes][index] = option
          end
          attrs[:check_boxes_attributes][field_num] = input
        when "Field::NumberField"
          input.delete(:_type)

          attrs[:number_fields_attributes][field_num] = input
        else
          field_num -= 1
        end
      end if inputs
      attrs
    end
  end

  # TODO: need_test
  def archive
    file = Tempfile.new('/tmp/excels', Rails.root)
    book = WriteExcel.new file.path
    sheet = book.add_worksheet(self.title || '未命名表单')
    format_bold = book.add_format
    format_bold.set_bold

    labels = self.inputs.map(&:label).unshift('提交用户')
    sheet.write 'A1', labels, format_bold

    identifiers = self.inputs.map(&:identifier)
    self.collections.each_with_index do |collection, index|
      values = []
      values.push collection.user.name
      identifiers.each do |identifier|
        entity = collection.entities.where(key: identifier).first
        values.push entity.get_value
      end
      sheet.write "A#{index + 2}", values
    end
    book.close
    file
  end

end
