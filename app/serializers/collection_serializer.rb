class CollectionSerializer < BasicCollectionSerializer
  has_one :user, serializer: BasicUserSerializer
end