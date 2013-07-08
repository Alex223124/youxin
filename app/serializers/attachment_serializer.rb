class AttachmentSerializer < ActiveModel::Serializer
  attributes :id,
             :file_name,
             :file_size,
             :file_type,
             :image,
             :src,
             :dimension

  def src
    "/attachments/#{object.id}"
  end
  def include_dimension?
    object.image?
  end
end
