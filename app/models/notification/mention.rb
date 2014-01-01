class Notification::Mention < Notification::Base
  validates :mentionable_id, presence: true
  validates :mentionable_type, presence: true

  belongs_to :mentionable, polymorphic: true

  after_create :send_mention_notifications

  def baidu_push_payload
    content = "#{mentionable.body}"[0...25]
    {
      type: :mention_notification,
      id: id.to_s,
      title: "#{mentionable.user.name}在评论里提到了你",
      content: content,
      user_id: mentionable.user_id.to_s
    }
  end

  def ios_payload
    {
      alert: "#{mentionable.user.name} 在评论里提到了你\n#{mentionable.body[0...20]}...",
      custom: {
        type: :comment,
        id: self.id.to_s
      }
    }
  end

  private
  def send_mention_notifications
    Notification::Notifier.publish_to_ios_device_async([user.id], ios_payload)
    Notification::Notifier.baidu_push_mention_to_android_async(self.id)
  end

end
