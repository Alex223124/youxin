class BaiduPushMentionToAndroidJob
  @queue = :baidu_push_queue

  def self.perform(mention_notification_id)
    mention_notification = Notification::Comment.where(id: mention_notification_id).first
    if mention_notification
      Notification::Notifier.push_messages_to_android_with_user_id_and_channel_id(mention_notification.user,
                                                                                  mention_notification.baidu_push_payload,
                                                                                  "mention_notification#{mention_notification.id}")
    end
  end
end
