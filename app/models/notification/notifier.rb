require "net/http"
require "net/https"

class Notification::Notifier
  include Notification::Backend
  class << self
    def publish_to_faye_client(users, data)
      users.each do |user|
        user = User.find(user) unless user.is_a? User
        if user && user.notification_channel?
          publish_faye_message(faye_message(user.notification_channel, data))
        end
      end
    end

    def publish_to_ios_device(users, data)
      ios_pusher = pusher
      users.each do |user|
        user = User.find(user) unless user.is_a? User
        if user && user.ios_device_token?
          notification = Grocer::Notification.new(grocer_message(user.ios_device_token, data))
          ios_pusher.push(notification)
        end
      end
    end

    def publish_to_phone(receipt)
      receipt = Receipt.find(receipt) unless receipt.is_a? Receipt
      if receipt && receipt.user.phone?
        content = receipt.post.body
        res = ChinaSMS.to(receipt.user.phone, content)
        CommunicationRecord::Sms.create receipt: receipt, status: res[:code]
      end
    end

    private
    def pusher
      certificate_file = File.join(Rails.root, 'push_server', 'grocer', 'certs', Youxin.config.apn.cert_file)
      Grocer.pusher(
        certificate: certificate_file,
        passphrase:  Youxin.config.apn.passphrase
      )
    end

    def grocer_message(token, data)
      message = data
      message[:device_token] = token
      message
    end

    def publish_faye_message(message)
      Thread.new do
        uri = URI.parse(Youxin.config.faye.server)
        Net::HTTP.post_form(uri, message: message.to_json)
      end
    end

    def faye_message(notification_channel, data)
      channel = "/#{Youxin.config.faye.subscription_prefix}/#{notification_channel}"
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