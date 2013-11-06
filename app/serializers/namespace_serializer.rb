class NamespaceSerializer < ActiveModel::Serializer
  attributes :name,
             :logo,
             :detailable

  def logo
    object.logo.url
  end
end
