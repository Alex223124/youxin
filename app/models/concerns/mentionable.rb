module Mentionable
  extend ActiveSupport::Concern

  included do
    field :mentioned_user_ids, type: Array, default: []

    before_save :extract_mentioned_users
    after_create :create_mention_notifications

    has_many :mention_notifications, as: :mentionable, class_name: 'Notification::Mention', dependent: :destroy
  end

  MENTION_REGX = /@([\p{Han}+\w]{2,10})/u

  def extract_mentioned_users
    names = body.scan(MENTION_REGX).flatten
    if names.any?
      self.mentioned_user_ids = User.where(:name => /^(#{names.join('|')})$/i,
                                           :_id.nin => no_mention_users.map(&:_id)).limit(3).only(:_id).map(&:_id).to_a
    end
  end

  def mentioned_users
    User.where(:_id.in => mentioned_user_ids)
  end

  def create_mention_notifications
    mentioned_users.each do |mentioned_user|
      mentioned_user.mention_notifications.create mentionable: self
    end
  end

  private
  def no_mention_users
    [user]
  end

end
