class Notification::Message < Notification::Base
  belongs_to :message, class_name: 'Message'

  validates :message_id, presence: true

end
