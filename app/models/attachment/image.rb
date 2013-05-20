class Attachment::Image < Attachment::Base
  field :file_name, type: String
  field :image, type: Boolean, default: true

  validates :file_name, presence: true

  mount_uploader :storage, ImageUploader

  before_validation :set_attachment_attributes, on: :create

  def details
    versions = []
    self.storage.versions.each_key do |version|
      versions << { version => self.storage.url(version) }
    end
    {
      file_name: self.file_name,
      versions: versions,
      url: self.storage.url
    }
  end

  protected
  def set_attachment_attributes
    if storage.present?
      self.file_name = self.storage.file.original_filename
    end
  end

end