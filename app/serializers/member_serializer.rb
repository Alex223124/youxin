class MemberSerializer < BasicUserSerializer
  attributes :position,
             :phone

  def position
    object.human_position_in_organization(organization)
  end
end