module Youxin
  module Entities
    class User < Grape::Entity
      expose :id, :name, :email, :created_at
    end

    class UserSafe < Grape::Entity
      expose :name
    end

    class UserBasic < Grape::Entity
      expose :id, :email, :name, :created_at
      expose :avatar do |user|
        user.avatar.url
      end
    end

    class UserLogin < UserBasic
      expose :private_token
    end

    class Attachment < Grape::Entity
      expose :id, :file_name
      expose :file_size
      expose :image
      expose :url do |attachment|
        attachment.storage.url
      end
    end

    class Post < Grape::Entity
      expose :title, :body, :body_html
      expose :author, using: Entities::UserBasic
      expose :attachments, using: Entities::Attachment
    end

    class OrganizationBasic < Grape::Entity
      expose :id, :name, :parent_id
    end

    class Receipt < Grape::Entity
      expose :id, :read, :organization_ids, :origin
      expose :post, using: Entities::Post
    end

  end
end
