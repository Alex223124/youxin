class PublishToIosDeviceJob
  @queue = :youxin_notification_queue

  def self.perform(users, data)
    Notification::Notifier.publish_to_ios_device(users, data)
  end
end
