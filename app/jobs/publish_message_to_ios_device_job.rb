class PublishMessageToIosDeviceJob
  @queue = :youxin_notification_queue

  def self.perform(message_id)
    Notification::Notifier.publish_message_to_ios_device(message_id)
  end
end
