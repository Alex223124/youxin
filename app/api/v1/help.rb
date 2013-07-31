class Attachments < Grape::API
  namespace :help do
    get :avatar_versions do
      Version.avatars
    end
    get :header_versions do
      Version.headers
    end
    get :tos do
      { tos: Youxin.config.help.tos }
    end
    get :privacy do
      { privacy: Youxin.config.help.privacy }
    end
    get :contact_email do
      { contact_email: Youxin.config.help.contact_email }
    end
  end
end