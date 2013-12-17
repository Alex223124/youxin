class BaiduPushCommentToAndroidJob
  @queue = :baidu_push_queue

  def self.perform(comment_notification_id)
    comment_notification = Notification::Comment.where(id: comment_notification_id).first
    if comment_notification
      Notification::Notifier.push_messages_to_android_with_user_id_and_channel_id(comment_notification.comment.commentable.author,
                                                                                  comment_notification.baidu_push_payload,
                                                                                  "comment_notification#{comment_notification.id}")
    end
  end
end
