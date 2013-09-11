class RecordReceiptSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user, serializer: RecordUserSerializer
  has_one :post, serializer: BasicPostSerializer
end
