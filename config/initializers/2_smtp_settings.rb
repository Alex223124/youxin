if Youxin::Application.config.action_mailer.delivery_method == :smtp
  ActionMailer::Base.smtp_settings = Youxin.config.smtp_settings
end
