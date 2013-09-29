class Help < Grape::API
  namespace :help do
    get :avatar_versions do
      Version.avatars
    end
    get :header_versions do
      Version.headers
    end
    get :about do
      {
        terms: Youxin.config.help.terms,
        privacy: Youxin.config.help.privacy,
        about_us: Youxin.config.help.about_us,
        ios_tips_and_tricks: Youxin.config.help.ios_tips_and_tricks,
        contact_email: Youxin.config.help.contact_email,
        faq: Youxin.config.help.faq
      }
    end
    get :last_android_version do
      {
        version: Youxin.config.help.android.version,
        url: Youxin.config.help.android.url
      }
    end
  end
end
