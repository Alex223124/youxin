class PasswordsController < Devise::PasswordsController
  # determine reset password by email or phone
  def create
    if resource_params['reset_password_key'] and resource_params['reset_password_key'].match /@/
      resource_params['email'] = resource_params.delete('reset_password_key')
      super
    else
      resource_params['phone'] = resource_params.delete('reset_password_key')
      self.resource = resource_class.send_reset_sms(resource_params)
      if successfully_sms_sent?(resource)
        respond_with({}, location: new_user_password_by_sms_path(phone: resource.phone))
      else
        respond_with(resource)
      end
    end
  end

  def new_by_sms
    self.resource = resource_class.find_or_initialize_with_errors([:phone], { phone: params[:phone] }, :not_found)
    redirect_to new_user_password_path, alert: resource.errors.full_messages.join(", ") unless resource.errors.empty?
    self.resource.reset_sms_token = nil
  end

  def edit_by_sms
    resource = resource_class.find_or_initialize_with_errors([:reset_sms_token], resource_params, :not_found)
    if resource.errors.empty?
      redirect_to edit_user_password_path(reset_sms_token: resource_params['reset_sms_token'])
    else
      redirect_to :back, alert: resource.errors.full_messages.join(", ")
    end
  end

  def edit
    if params[:reset_sms_token]
      self.resource = resource_class.new
      resource.reset_sms_token = params[:reset_sms_token]
    else
      super
    end
  end

  def update
    if resource_params['reset_password_token']
      super
    else
      self.resource = resource_class.reset_password_by_sms(resource_params)

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
        if resource.errors.has_key?(:reset_sms_token)
          redirect_to new_user_password_by_sms_path(phone: resource.phone), alert: resource.errors.full_messages.join(", ")
        else
          respond_with resource
        end
      end
    end
  end

  protected
  def successfully_sms_sent?(resource)
    notice = if Devise.paranoid
      resource.errors.clear
      :send_paranoid_sms
    elsif resource.errors.empty?
      :send_sms
    end

    if notice
      set_flash_message :notice, notice if is_navigational_format?
      true
    end
  end
  def assert_reset_token_passed
    if params[:reset_sms_token].blank?
      super
    end
  end

  def after_sign_in_path_for(resource)
     if is_mobile_device?
       app_path
     else
       super(resource)
     end
  end


end
