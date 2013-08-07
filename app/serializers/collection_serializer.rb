class CollectionSerializer < ActiveModel::Serializer
  attributes :entities
  
  has_one :user, serializer: BasicUserSerializer

  def entities
    object.entities.as_json(only: [:key, :value])
  end
end