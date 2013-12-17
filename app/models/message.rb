class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body

  validates :body, presence: true
  validates :user_id, presence: true
  validates :conversation_id, presence: true

  belongs_to :user
  belongs_to :conversation
  has_many :message_notifications, class_name: 'Notification::Message', dependent: :destroy

  default_scope desc(:_id)

  after_create do
    update_conversation
    send_message_notifications
  end

  def baidu_push_payload
    content = "#{self.body}"[0...25]
    {
      type: :conversation,
      id: self.conversation.id.to_s,
      title: "#{self.user.name}发来一条私信",
      content: content,
      user_id: self.user_id.to_s
    }
  end

  private
  def update_conversation
    self.conversation.last_message_id = self.id
    self.conversation.updated_at = self.created_at
    self.conversation.save
  end
  def send_message_notifications
    other_participants = self.conversation.participants - [self.user]
    Notification::Notifier.publish_to_faye_client_async(other_participants.map(&:id), faye_payload)
    other_participants.each do |participant|
      participant.message_notifications.create(message_id: self.id)
    end
    Notification::Notifier.publish_message_to_ios_device_async(self.id)
    Notification::Notifier.baidu_push_message_to_android_async(self.id)
  end
  def faye_payload
    self.as_json(only: [:created_at, :body], methods: [:id], root: true,
                  include: {
                    user: { only: [:name], methods: [:id, :avatar_url] },
                    conversation: { only: [:created_at, :updated_at], methods: [:id] }
                  })
  end
end
