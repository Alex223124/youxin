class OrganizationSerializer < BasicOrganizationSerializer
  has_one :parent, serializer: BasicOrganizationSerializer
  has_many :children, serializer: BasicOrganizationSerializer
end