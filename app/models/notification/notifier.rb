# encoding: utf-8

require "net/http"
require "net/https"

class Notification::Notifier
  include Notification::Backend
  class << self
    def publish_to_faye_client(users, data)
      users.each do |user|
        user = User.find(user) unless user.is_a? User
        if user && user.notification_channel?
          publish_faye_message(faye_message(user.notification_channel, data)).join
        end
      end
    end
    def publish_post_to_faye_client(post_id)
      post = Post.where(id: post_id).first unless post.is_a?(Post)
      post.receipts.all.each do |receipt|
        user = receipt.user
        if user.notification_channel?
          publish_faye_message(faye_message(user.notification_channel, receipt.faye_payload)).join
        end
      end
    end

    def publish_to_ios_device(users, data)
      ios_pusher = pusher
      users.each do |user|
        user = User.find(user) unless user.is_a? User
        if user && user.ios_device_tokens?
          user.ios_device_tokens.each do |ios_device_token|
            notification = Grocer::Notification.new(grocer_message(ios_device_token, data))
            ios_pusher.push(notification)
          end
        end
      end
    end
    def publish_post_to_ios_device(post)
      ios_pusher = pusher
      post = Post.where(id: post).first unless post.is_a?(Post)
      post.receipts.all.each do |receipt|
        user = receipt.user
        if user.ios_device_tokens?
          user.ios_device_tokens.each do |ios_device_token|
            notification = Grocer::Notification.new(
              grocer_message(
                ios_device_token,
                receipt.ios_payload)
            )
            ios_pusher.push(notification)
          end
        end
      end
    end
    def publish_message_to_ios_device(message)
      ios_pusher = pusher
      message = Message.where(id: message).first unless message.is_a?(Message)
      message.message_notifications.each do |message_notification|
        user = message_notification.user
        if user.ios_device_tokens?
          user.ios_device_tokens.each do |ios_device_token|
            notification = Grocer::Notification.new(
              grocer_message(
                ios_device_token,
                message_notification.ios_payload)
            )
            ios_pusher.push(notification)
          end
        end
      end
    end

    def publish_to_phone(receipt)
      receipt = Receipt.find(receipt) unless receipt.is_a? Receipt
      if receipt && receipt.user.phone?
        post = receipt.post
        content = "#{post.author.name}: 您有一条新优信[#{post.title}]。详情点击： #{receipt.short_url} 【Combee】"
        res = message(receipt.user.phone, content)
        CommunicationRecord::Sms.create receipt: receipt, status: res[:code]
      end
    end

    def make_landing_call_to_phone(receipt)
      receipt = Receipt.find(receipt) unless receipt.is_a? Receipt
      if receipt && receipt.user.phone?
        post = receipt.post
        content = "您好！您收到了#{post.author.name}通过combee给您的电话留言：您有一条新优信，#{post.title}，请尽快登陆combee网站或移动客户端查看详细信息。留言已结束，感谢您的收听，再见。"

        landing_call = call receipt.user.phone, media_txt: content
        call_sid = landing_call.response.body[:landing_call][:call_sid] rescue nil
        CommunicationRecord::Call.create receipt: receipt, status: landing_call.response.status_code, call_sid: call_sid
      end
    end

    def message(phone, content)
      ChinaSMS.to(phone, content)
    end
    def call(phone, params)
      cloopen_account.calls.landing_calls.create params.merge(to: phone)
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
        url = URI.parse(Youxin.config.faye.server)
        form = Net::HTTP::Post.new(url.path.empty? ? '/' : url.path)
        form.set_form_data(message: message.to_json)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = url.scheme == "https"
        http.start {|h| h.request(form)}
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

    def cloopen_account
      account_sid = Youxin.config.cloopen.account_sid
      auth_token = Youxin.config.cloopen.auth_token
      app_id = Youxin.config.cloopen.app_id

      client = Cloopen::REST::Client.new(account_sid, auth_token, app_id)
      client.account
    end

  end
end
