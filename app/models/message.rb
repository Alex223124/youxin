class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body

  validates :body, presence: true
  validates :user, presence: true
  validates :conversation, presence: true

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
    (self.conversation.participants - [self.user]).each do |participant|
      participant.message_notifications.create(message_id: self.id)
    end
  end
end
