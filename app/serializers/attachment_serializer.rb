class AttachmentSerializer < ActiveModel::Serializer
  attributes :id,
             :file_name,
             :file_size,
             :file_type,
             :src

  def src
    "/attachments/#{object.id}"
  end
  def file_size
    if object.image?
      nil
    else
      object.file_size
    end
  end
 
end
