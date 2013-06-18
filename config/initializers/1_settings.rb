# # # # # # # # # # # # # # # # # # # # # # #
#             Youxin config                 #
# # # # # # # # # # # # # # # # # # # # # # #
# access config through `Youxin.config`
# set in youxin.yml
# Example:
# setter `Settings['app_name'] = 'youxin'`
# getter `Youxin.config.app_name = 'youxin'`

class Settings < Settingslogic
  source "#{Rails.root}/config/youxin.yml"
  namespace Rails.env
  load! if Rails.env.development?
end

module Youxin
  def self.config
    Settings
  end
end