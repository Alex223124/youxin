class FormSerializer < BasicFormSerializer
  attributes :filleds,
             :unfilleds

  has_many :inputs, serializer: InputSerializer

  def filleds
    object.post.receipts.filled.count rescue 0
  end
  def unfilleds
    object.post.receipts.unfilled.count rescue 0
  end

end