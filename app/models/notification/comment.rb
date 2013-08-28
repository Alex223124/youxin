# encoding: utf-8

class Notification::Comment < Notification::Base
  belongs_to :comment, class_name: 'Comment'

  validates :comment_id, presence: true

  after_create :send_comment_notification_to_ios_device

  private
  def send_comment_notification_to_ios_device
    Notification::Notifier.publish_to_ios_device_async([self.user.id], ios_payload)
  end
  def ios_payload
    {
      alert: "#{comment.user.name} 评论了你的优信\n#{comment.body[0...20]}...",
      custom: {
        type: :comment,
        id: self.id.to_s,
      }
    }
  end

end
