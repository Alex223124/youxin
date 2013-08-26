class PublishToFayeClientJob
  @queue = :youxin_notification_queue

  def self.perform(user_ids, data)
    Notification::Notifier.publish_to_faye_client(user_ids, data)
  end
end
