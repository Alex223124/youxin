class DeviseMailer < Devise::Mailer
  include Devise::Mailers::Helpers
  class << self
    def mailer_name
      DeviseMailer.superclass.name.underscore
    end
  end

  def welcome_instructions(record, opts={})
    devise_mail(record, :welcome_instructions, opts)
  end
end
