class PublishToPhoneJob
  @queue = :youxin_notification_queue

  def self.perform(receipt)
    Notification::Notifier.publish_to_phone(receipt)
  end
end
