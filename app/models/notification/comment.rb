# encoding: utf-8

class Notification::Comment < Notification::Base
  belongs_to :comment, class_name: 'Comment'

  validates :comment_id, presence: true

  after_create :send_comment_notifications

  private
  def send_comment_notifications
    Notification::Notifier.publish_to_ios_device_async([user.id], ios_payload)
    Notification::Notifier.publish_to_faye_client_async([user_id], faye_payload)
  end
  def ios_payload
    {
      alert: "#{comment.user.name} 评论了你的优信\n#{comment.body[0...20]}...",
      custom: {
        type: :comment,
        id: self.id.to_s
      }
    }
  end
  def faye_payload
    {
      'comment_notification' =>
        self.as_json(only: [:read, :created_at],
                      methods: [:id],
                      include: {
                        comment: {
                          only: [:commentable_type, :body],
                          include: {
                            commentable: {
                              only: [:title, :body, :created_at],
                              methods: [:id],
                            },
                            user: {
                              only: [:name],
                              methods: [:id, :avatar_url]
                            }
                          }
                        }
                    })
    }
  end
end
