class BasicOrganizationSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :avatar

  def avatar
    object.avatar.url
  end
end