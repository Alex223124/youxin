# encoding: utf-8

module BaiduTaggable
  extend ActiveSupport::Concern
  include Youxin::Util

  included do
    field :tag, type: String

    before_create do
      ensure_tag
    end

    after_destroy do
      baidu_push_client.delete_tag self.tag
    end
  end

  def baidu_push_users
    []
  end

  def reset_tag
    begin
      self.tag = generate_random_string
    end while tag_exists?
  end

  def reset_tag!
    baidu_push_client.delete_tag self.tag
    self.baidu_push_users.each do |user|
      user.pull_tag(self.tag)
    end
    reset_tag
    save(:validate => false)

    self.baidu_push_users.each do |user|
      user.push_tag(self.tag)
    end
  end

  def ensure_tag
    reset_tag if tag.blank?
  end

  def ensure_tag!
    reset_tag! if tag.blank?
  end

  private
  def tag_exists?
    Organization.where(tag: tag).exists? ||
      Conversation.where(tag: tag).exists?
  end

end

