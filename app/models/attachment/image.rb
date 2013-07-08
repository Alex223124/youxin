class Attachment::Image < Attachment::Base
  field :file_name, type: String
  field :image, type: Boolean, default: true
  field :file_type, type: String
  field :file_size, type: String
  field :dimension, type: String

  validates :file_name, presence: true

  mount_uploader :storage, ImageUploader

  before_validation :set_attachment_attributes, on: :create

  def url
    "/attachments/#{self.id}"
  end

  def details
    versions = {}
    self.storage.versions.each_key do |version|
      versions[version.to_sym] = self.storage.url(version)
    end
    {
      id: self.id,
      file_name: self.file_name,
      file_type: self.file_type,
      file_size: self.file_size,
      versions: versions,
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