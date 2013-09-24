class Password < Grape::API
  resource :password do
    post do
      if params[:email]
        resource = User.send_reset_password_instructions(email: params[:email])
      elsif params[:phone]
        resource = User.send_reset_sms(phone: params[:phone])
      else
        bad_request! [:reset_password_key]
      end

      if resource.errors.empty?
        present resource, with: Youxin::Entities::UserSimple
      else
        fail!(resource.errors)
      end
    end

    get :valid_token do
      required_attributes! [:reset_sms_token, :phone]
      resource_params = attributes_for_keys [:reset_sms_token, :phone]

      resource = User.find_or_initialize_with_errors([:reset_sms_token], resource_params, :not_found)
      resource.errors.add(:reset_sms_token, :expired) unless resource.reset_sms_period_valid?

      if resource.errors.empty?
        present resource, with: Youxin::Entities::UserSimple
      else
        fail!(resource.errors)
      end
    end

    put do
      required_attributes! [:reset_sms_token, :password, :password_confirmation]
      resource_params = attributes_for_keys [:reset_sms_token, :password, :password_confirmation]

      resource = User.reset_password_by_sms(resource_params)
      if resource.errors.empty?
        status(204)
      else
        fail!(resource.errors)
      end
    end
  end
end
