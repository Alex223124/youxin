source 'http://ruby.taobao.org'

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

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'mongoid-rspec'
  gem 'factory_girl_rails'

  gem 'mongoid_colored_logger'

  gem 'guard-rspec', '~> 2.5.4'
  # Notification
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  # speed up test
  gem 'guard-spork'
end

gem 'slim-rails' # html template
gem 'bootstrap-sass', '~> 2.3.1.0' # bootstrap
gem 'angularjs-rails', '~> 1.0.6' # angularjs
gem 'simple_form'