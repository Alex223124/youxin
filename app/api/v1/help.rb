class Attachments < Grape::API
  namespace :help do
    get :avatar_versions do
      Version.avatars
    end
    get :header_versions do
      Version.headers
    end
  end
end