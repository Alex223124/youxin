module Youxin
  module Util
    extend self

    def generate_random_string
      SecureRandom.base64(4).tr('+/', '-_')
    end

    def baidu_push_client
      BaiduPush::Client.new(Youxin.config.baidu_push.api_key, Youxin.config.baidu_push.secret_key)
    end
  end
end
