# encoding: utf-8

class SendWelcomeMessageJob
  @queue = :youxin_scheduler_queue

  def self.perform(user_id)
    user = User.where(id: user_id).first
    content = "#{user.creator.name}：邀请您使用Combee—组织消息通知中心，加入组织#{user.organizations.first.name}。请尽快登陆 https://combee.co/welcome"

    Notification::Notifier.message(user.phone, content) if user.phone?
  end
end
