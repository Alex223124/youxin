class BasicCollectionSerializer < ActiveModel::Serializer
  attributes :entities

  def entities
    object.entities.as_json(only: [:key, :value])
  end
end