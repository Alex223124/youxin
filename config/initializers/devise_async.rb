Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :resque
  config.queue   = :youxin_devise
end
