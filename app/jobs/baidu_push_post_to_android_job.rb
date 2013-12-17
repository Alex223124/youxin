class BaiduPushPostToAndroidJob
  @queue = :baidu_push_queue

  def self.perform(post_id)
    post = Post.where(id: post_id).first
    if post
      Notification::Notifier.push_messages_to_android_with_tags(post.tags,
                                                                post.baidu_push_payload,
                                                                "post#{post_id}")
    end
  end
end
