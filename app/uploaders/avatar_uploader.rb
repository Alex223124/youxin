require 'carrierwave/mongoid'
class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog
  storage :grid_fs

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "/uploads/avatar"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # asset_path("avatar/" + [version_name, "default.png"].compact.join('_'))
  
    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
    "/assets/avatar/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  version :small do
    process resize_to_fill: [50, 50]
  end
  
  version :normal do
    process resize_to_fill: [80, 80]
  end 

  version :big do
    process resize_to_fill: [130, 130]
  end 

  version :huge do
    process resize_to_fill: [200, 200]
  end 

  version :mobile do
    process resize_to_fill: [130, 130]
  end

  # For retina
  version :retina_small do
    process resize_to_fill: [100, 100]
  end

  version :retina_normal do
    process resize_to_fill: [160, 160]
  end

  version :retina_big do
    process resize_to_fill: [260, 260]
  end

  version :retina_huge do
    process resize_to_fill: [400, 400]
  end

  version :retina_mobile do
    process resize_to_fill: [260, 260]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    # "something.jpg" if original_filename
    "#{model.id}.#{file.extension.downcase}" if super.present?
  end

end