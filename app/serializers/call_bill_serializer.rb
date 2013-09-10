class CallBillSerializer < ActiveModel::Serializer
  attributes :created_at,
             :human_status

  has_one :receipt, serializer: RecordReceiptSerializer
end
