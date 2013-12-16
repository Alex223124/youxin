# encoding: utf-8

module BaiduTaggable
  extend ActiveSupport::Concern
  include Youxin::Util

  included do
    field :tag, type: String

    before_create do
      ensure_tag
    end
  end

  def reset_tag
    begin
      self.tag = generate_random_string
    end while tag_exists?
  end

  def reset_tag!
    reset_tag
    save(:validate => false)
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

