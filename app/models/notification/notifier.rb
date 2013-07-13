require "net/http"
require "net/https"

class Notification::Notifier
  class << self
    def publish_to_faye_client(channel, data)
      publish_message(message(channel, data))
    end

    private
    def publish_message(message)
      Thread.new do
        uri = URI.parse(Youxin.config.faye.server)
        Net::HTTP.post_form(uri, message: message.to_json)
      end
    end

    def message(channel, data)
      channel = "/#{Youxin.config.faye.subscription_prefix}/#{channel}"
      message = { channel: channel, data: { token: Youxin.config.faye.token } }
      if data.kind_of? String
        message[:data][:eval] = data
      else
        message[:data][:json] = data
      end
      message
    end

  end
end