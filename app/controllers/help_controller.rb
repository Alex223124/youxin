class HelpController < ApplicationController
  def positions
    positions = Position.all.as_json(only: :name, methods: :id)
    render json: { positions: positions }
  end
end