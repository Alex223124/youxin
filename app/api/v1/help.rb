class Help < Grape::API
  namespace :help do
    get :avatar_versions do
      Version.avatars
    end
    get :header_versions do
      Version.headers
    end
    get :terms do
      {
        terms:
        {
          text: Youxin.config.help.terms.text,
          url: Youxin.config.help.terms.url
        }
      }
    end
    get :privacy do
      {
        privacy:
        {
          text: Youxin.config.help.privacy.text,
          url: Youxin.config.help.privacy.url
        }
      }
    end
    get :about_us do
      {
        about_us:
        {
          text: Youxin.config.help.about_us.text,
          url: Youxin.config.help.about_us.url
        }
      }
    end
    get :contact_email do
      { contact_email: Youxin.config.help.contact_email }
    end
  end
end