source 'https://rubygems.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end
def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem 'rails', '3.2.13'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '~> 2.2.1'

gem 'mongoid'
gem 'carrierwave-mongoid', '~> 0.5.0'
gem 'mini_magick', '~> 3.5.0'
gem 'mime-types', '~> 1.23'
gem 'kaminari'

gem 'active_model_serializers', '~> 0.8.0'

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'mongoid-rspec'
  gem 'factory_girl_rails'
  gem 'webmock'

  gem 'guard-rspec', '~> 2.5.4'
  # Notification
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  gem 'guard-spork' # speed up test
end
group :development, :test do
  gem 'thin'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-nav'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'mongoid_colored_logger'

  gem 'quiet_assets', '~> 1.0.2' # disable assets log
  gem 'faker' # fake data
end

gem 'slim-rails' # html template
gem 'bootstrap-sass', '~> 2.3.1.0' # bootstrap
gem 'angularjs-rails', '~> 1.0.6' # angularjs
gem 'simple_form'
gem 'font-awesome-sass-rails'

# Youxin settings
gem 'settingslogic', '~> 2.0.9'

# Authentication
gem 'devise', '~> 2.2.3'
# Authorization
gem 'six', '~> 0.2.0'
# Finite state machine
gem 'workflow_on_mongoid'

gem 'spreadsheet' # parse Excel file

gem 'nokogiri', '~> 1.5.9' # parse HTML to Plain Text

gem 'grape', '~> 0.5.0' # API
gem 'grape-entity', github: 'fahchen/grape-entity', branch: :master

gem 'grocer' # APNs
gem 'china_sms' # smsbao

# Background jobs
gem 'resque-scheduler', require: 'resque_scheduler'
