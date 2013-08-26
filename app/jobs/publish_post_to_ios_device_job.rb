class PublishPostToIosDeviceJob
  @queue = :youxin_notification_queue

  def self.perform(post_id)
    Notification::Notifier.publish_post_to_ios_device(post_id)
  end
end
