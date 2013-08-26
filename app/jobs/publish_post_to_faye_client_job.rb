class PublishPostToFayeClientJob
  @queue = :youxin_notification_queue

  def self.perform(post_id)
    Notification::Notifier.publish_post_to_faye_client(post_id)
  end
end
