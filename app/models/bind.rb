class Bind
  include Mongoid::Document
  field :baidu_channel_id, type: String
  field :baidu_user_id, type: String

  validates :baidu_user_id, uniqueness: { scope: :baidu_channel_id }

  belongs_to :user
end
