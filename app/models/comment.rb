class Comment
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :body, type: String

  validates :body, presence: true
  validates :commentable_id, presence: true
  validates :commentable_type, presence: true
  validates :user_id, presence: true

  belongs_to :commentable, polymorphic: true
  belongs_to :user
  has_many :comment_notifications, class_name: 'Notification::Comment', dependent: :destroy

  default_scope desc(:_id)

  after_create do
    send_comment_notifications
  end

  private
  def send_comment_notifications
    self.commentable.author.comment_notifications.create(comment_id: self.id) unless self.commentable.author == self.user
  end
end
