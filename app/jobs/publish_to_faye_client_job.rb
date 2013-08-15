class PublishToFayeClientJob
  @queue = :youxin_notification_queue

  def self.perform(users, data)
    Notification::Notifier.publish_to_faye_client(users, data)
  end
end
