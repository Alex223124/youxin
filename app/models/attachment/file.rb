class Attachment::File < Attachment::Base
  field :file_name, type: String
  field :file_size, type: String
  field :image, type: Boolean, default: false

  validates :file_name, presence: true
  validates :file_size, presence: true

  mount_uploader :storage, FileUploader

  before_validation :set_attachment_attributes, on: :create

  def details
    {
      file_name: self.file_name,
      file_size: self.file_size,
      url: self.storage.url
    }
  end

  protected
  def set_attachment_attributes
    if storage.present?
      self.file_size = self.storage.file.size
      self.file_name = self.storage.file.original_filename
    end
  end


end