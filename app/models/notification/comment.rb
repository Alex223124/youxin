class Notification::Comment < Notification::Base
  belongs_to :comment, class_name: 'Comment'

  validates :comment_id, presence: true

end
