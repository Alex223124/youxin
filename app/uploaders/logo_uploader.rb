require 'carrierwave/mongoid'
class LogoUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :grid_fs

  def store_dir
    "/uploads/logo/#{model.class.to_s.underscore}"
  end

  def default_url
    "/assets/logo/default.png"
  end

  Version.logos.each do |v|
    version v[:name] do
      process v[:process] => v[:dimension]
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{model.id}_#{Digest::MD5.hexdigest(File.dirname(current_path))}.#{file.extension.downcase}" if super.present?
  end

end
