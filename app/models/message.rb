class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body

  validates :body, presence: true
  validates :user, presence: true
  validates :conversation, presence: true

  belongs_to :user
  belongs_to :conversation

  default_scope desc(:_id)

end
