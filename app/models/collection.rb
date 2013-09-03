class Collection
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  belongs_to :form
  belongs_to :user

  attr_accessible :form_id, :user_id, :entities_attributes

  validates :form_id, presence: true
  validates :user_id, presence: true

  embeds_many :entities

  accepts_nested_attributes_for :entities

  after_save :update_receipt

  class << self
    def clean_attributes_with_entities(attrs = {}, reference_form)
      nested_attrs = {}
      nested_attrs[:entities_attributes] = {}
      attrs = attrs.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}

      reference_form.inputs.map(&:identifier).each_with_index do |identifier, index|
        nested_attrs[:entities_attributes][index] = { key: identifier, value: attrs[identifier.to_s] }
      end
      nested_attrs
    end
    def clean_attributes_for_update(attrs = {}, reference_collection)
      nested_attrs = {}
      nested_attrs[:entities_attributes] = {}
      attrs = attrs.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}

      reference_collection.entities.each_with_index do |entity, index|
        nested_attrs[:entities_attributes][index] = { id: entity.id, value: attrs[entity.key] }
      end
      nested_attrs
    end
  end

  private
  def update_receipt
    post = form.post
    return unless post
    receipt = post.receipts.where(user_id: user_id).first
    receipt.update_attributes(forms_filled: true)
  end

end
