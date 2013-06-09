class ReceiptSerializer < ActiveModel::Serializer
  attributes :id,
             :read,
             :origin
 
  has_one :post, serializer: BasicPostSerializer
  has_one :author, serializer: BasicUserSerializer
  has_many :organizations, serializer: BasicOrganizationSerializer
  has_many :organization_clans, serializer: BasicOrganizationSerializer

  def organizations
    if object.origin?
      object.post.organizations
    else
      object.organizations
    end
  end
  def organization_clans
    object.post.organization_clans
  end
  def include_organization_clans?
    object.origin?
  end

end
