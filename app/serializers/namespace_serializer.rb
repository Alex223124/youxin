class NamespaceSerializer < ActiveModel::Serializer
  attributes :name,
             :logo

  def logo
    object.logo.url
  end
end
