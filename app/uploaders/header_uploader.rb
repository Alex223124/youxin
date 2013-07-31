require 'carrierwave/mongoid'
class HeaderUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :grid_fs

  Version.headers.each do |v|
    version v[:name] do
      process v[:process] => v[:dimension]
    end
  end

  # version :ipad do
  #   process resize_to_fill: [626, 313]
  # end
  # version :mobile_retina do
  #   process resize_to_fill: [640, 320]
  # end
  # version :mobile do
  #   process resize_to_fill: [320, 160]
  # end
  # version :web_retina do
  #   process resize_to_fill: [1040, 520]
  # end
  # version :ipad_retina do
  #   process resize_to_fill: [1252, 626]
  # end
  # version :web do
  #   process resize_to_fill: [520, 260]
  # end

  def store_dir
    "/uploads/header/#{model.class.to_s.underscore}"
  end

  def default_url
    "/assets/header/#{model.class.to_s.underscore}/" + [version_name, "default.png"].compact.join('_')
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def filename
    "#{model.id}.#{file.extension.downcase}" if super.present?
  end

end
