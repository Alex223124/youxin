class BaiduPushMessageToAndroidJob
  @queue = :baidu_push_queue

  def self.perform(message_id)
    message = Message.where(id: message_id).first
    if message
      Notification::Notifier.push_messages_to_android_with_tags(message.conversation.tags,
                                                                message.baidu_push_payload,
                                                                "conversation#{message.conversation.id}")
    end
  end
end
