class BaiduPushMessageToAndroidJob
  @queue = :baidu_push_queue

  def self.perform(message_id)
    message = Message.where(id: message_id).first
    if message
      Notification::Notifier.push_messages_to_android_with_tags([message.conversation.tag], message.baidu_push_payload, message.conversation.id)
    end
  end
end
