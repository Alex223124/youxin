module MobileDetect
  extend ActiveSupport::Concern

  # From mobile-fu: http://github.com/brendanlim/mobile-fu
  MOBILE_USER_AGENT_REGX = %r(palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|
                              audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|
                              x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|
                              pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|
                              webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|
                              mobile')

  def user_agent
    request.user_agent
  end

  def is_mobile_device?
    user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENT_REGX)
  end
end
