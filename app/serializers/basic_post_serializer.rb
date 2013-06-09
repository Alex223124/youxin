class BasicPostSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :body,
             :body_html,
             :created_at,
             :attachmentted,
             :formed

  def attachmentted
    object.attachments?
  end
  def formed
    object.forms?
  end
end