class BasicOrganizationSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :avatar

  def avatar
    hash = {}
    object.avatar.versions.each do |k, v|
      hash[k] = v.url
    end
    hash[:default] = object.avatar.url
    hash
  end
end