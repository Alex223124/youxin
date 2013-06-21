CarrierWave.configure do |config|
	config.storage = :grid_fs
  config.grid_fs_access_url = "/"
  config.permissions = 0600
  config.directory_permissions = 0700
end