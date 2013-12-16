class Bind
  include Mongoid::Document
  field :baidu_channel_id, type: String
  field :baidu_user_id, type: String

  validates :baidu_channel_id, presence: true
  validates :baidu_user_id, presence: true, uniqueness: { scope: :baidu_channel_id }
  validates :user_id, presence: true

  belongs_to :user

  after_create do
    self.user.bind_to_server(self)
  end

  after_destroy do
    self.user.unbind_from_server(self)
  end
end
