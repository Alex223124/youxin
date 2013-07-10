class ReceiptAdminSerializer < ActiveModel::Serializer
  attributes :id,
             :read,
             :read_at
  has_one :user, serializer: BasicUserSerializer
end