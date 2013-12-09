class Session < Grape::API
  # Login to get token
  #
  # Example Request:
  #  POST /session
  post "/session" do
    required_attributes! [:login, :password]
    resource = User.find_for_database_authentication(login: params[:login])

    return unauthorized! unless resource

    if resource.valid_password?(params[:password])
      resource.update_tracked_fields!(warden.request)
      present resource, with: Youxin::Entities::UserLogin
    else
      unauthorized!
    end
  end
end
