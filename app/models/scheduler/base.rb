class Scheduler::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  field :delayed_at, type: DateTime
  field :ran_at, type: DateTime

  validates :delayed_at, presence: true
  validates :user_id, presence: true
  validates :post_id, presence: true

  belongs_to :user
  belongs_to :post

  default_scope desc(:_id)

  before_validation do
    self.user_id = self.post.author_id
  end
end
