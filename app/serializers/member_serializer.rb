class MemberSerializer < BasicUserSerializer
  attributes :position,
             :phone

  def position
    object.position_in_organization(organization).as_json(only: :name, methods: :id)
  end
end