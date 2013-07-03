RSpec.configure do |config|
  config.include Mongoid::Matchers
  config.before(:each) { Mongoid::IdentityMap.clear }
end
