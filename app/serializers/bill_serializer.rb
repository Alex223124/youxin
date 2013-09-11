class BillSerializer < ActiveModel::Serializer
  attributes :created_at,
             :human_status,
             :origin_receipt_id

  has_one :receipt, serializer: RecordReceiptSerializer

  def origin_receipt_id
    object.receipt.post.receipts.where(origin: true).first.id rescue nil
  end
end
