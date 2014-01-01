class Comment
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields
  include Mentionable

  field :body, type: String

  attr_accessible :body, :user_id,
                  :commentable_id, :commentable_type

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
    add_commentable_can_mention_user
  end
  after_destroy do
    remove_commentable_can_mention_user
  end

  private
  def send_comment_notifications
    self.commentable.author.comment_notifications.create(comment_id: self.id) unless self.commentable.author == self.user
  end

  def add_commentable_can_mention_user
    commentable.add_can_mention_users(user) unless user == commentable.author
  end
  def remove_commentable_can_mention_user
    commentable.remove_can_mention_users(user) unless user == commentable.author
  end

  def allow_mention_users
    super + commentable.can_mention_users - [user]
  end
end
