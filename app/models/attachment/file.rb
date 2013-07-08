class Attachment::File < Attachment::Base
  field :file_name, type: String
  field :file_size, type: String
  field :file_type, type: String
  field :image, type: Boolean, default: false

  validates :file_name, presence: true
  validates :file_size, presence: true

  mount_uploader :storage, FileUploader

  before_validation :set_attachment_attributes, on: :create

  def url
    "/attachments/#{self.id}"
  end

  def details
    {
      id: self.id,
      file_name: self.file_name,
      file_size: self.file_size,
      file_type: self.file_type,
      url: "/attachments/#{self.id}"
    }
  end

  protected
  def set_attachment_attributes
    if storage.present?
      self.file_size = self.storage.file.size
      self.file_name = self.storage.file.original_filename
      self.file_type = self.storage.file.content_type
    end
  end

end