# encoding: utf-8

class Notification::Message < Notification::Base
  belongs_to :message, class_name: 'Message'

  validates :message_id, presence: true

  def ios_payload
    {
      alert: "#{message.user.name}:\n(私信) #{message.body[0...20]}...",
      custom: {
        type: :message,
        id: id.to_s,
      }
    }
  end

end
