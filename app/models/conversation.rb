class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaiduTaggable

  field :originator_id
  field :last_message_id

  validates :originator_id, presence: true

  has_and_belongs_to_many :participants, class_name: 'User'
  has_many :messages, dependent: :destroy

  default_scope desc(:updated_at)

  after_create do
    self.participants.each do |participant|
      participant.push_tag(self.tag)
    end
  end

  after_destroy do
    self.participants.each do |participant|
      participant.pull_tag(self.tag)
    end
  end

  def self.allowed(object, subject)
    return [] unless object.instance_of?(User)
    return [] unless subject.instance_of?(Conversation)
    abilities = []
    abilities |= [:read] if subject.participant_ids.include?(object.id)
    abilities |= [:read, :manage] if subject.originator_id == object.id
    abilities
  end

  def baidu_push_users
    self.participants
  end

  def originator
    User.where(id: self.originator_id).first
  end
  def last_message
    Message.where(id: self.last_message_id).first
  end

  def remove_user(user)
    user = User.where(id: user).first unless user.is_a? User
    return false unless user
    user.pull(:conversation_ids, self.id)
    self.pull(:participant_ids, user.id)
    user.remove_tag(self.tag)
  end
  def add_user(user)
    user = User.where(id: user).first unless user.is_a? User
    return false unless user
    self.participants.push(user)
    user.add_tag(self.tag)
  end
end
