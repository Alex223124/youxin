class AuthorizedOrganizationSerializer < BasicOrganizationSerializer
  attributes :parent_id,
             :members_count,
             :bio

  def members_count
    object.members.count
  end

end