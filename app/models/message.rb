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

  private
  def update_conversation
    self.conversation.last_message_id = self.id
    self.conversation.updated_at = self.created_at
    self.conversation.save
  end
  def send_message_notifications
    other_participants = self.conversation.participants - [self.user]
    Notification::Notifier.publish_to_faye_client(other_participants, message_hash)
    other_participants.each do |participant|
      participant.message_notifications.create(message_id: self.id)
    end
  end
  def message_hash
    # Issue _id and id in Mongoid
    # self.as_json(only: [:_id, :created_at, :body],
    #                 include: {
    #                   user: { only: [:_id, :name] },
    #                   conversation: { only: [:_id, :created_at, :updated_at] }
    #                 })
    hash = {
      id: self.id,
      created_at: self.created_at,
      body: self.body,
      user: {
        id: self.user.id,
        name: self.user.name,
        avatar: self.user.avatar
      },
      conversation: {
        id: self.conversation.id,
        created_at: self.conversation.created_at,
        updated_at: self.conversation.updated_at
      }
    }
  end
end
