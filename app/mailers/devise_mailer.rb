class DeviseMailer < Devise::Mailer
  include Devise::Mailers::Helpers
  class << self
    def mailer_name
      DeviseMailer.superclass.name.underscore
    end
  end

  def welcome_instructions(record, opts={})
    record.send :generate_reset_password_token! if record.send :should_generate_reset_token?
    devise_mail(record, :welcome_instructions, opts)
  end
end
