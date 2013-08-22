class HelpController < ApplicationController
  def positions
    positions = current_namespace.positions.as_json(only: :name, methods: :id)
    render json: { positions: positions }
  end
  def roles
    roles = current_namespace.roles.as_json(only: :name, methods: :id)
    render json: { roles: roles }
  end
end