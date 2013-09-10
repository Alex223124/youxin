class RecordReceiptSerializer < ActiveModel::Serializer
  has_one :user, serializer: RecordUserSerializer
  has_one :post, serializer: BasicPostSerializer
end
