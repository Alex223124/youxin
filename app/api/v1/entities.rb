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
      expose :id, :title, :body, :body_html
      expose :author, using: Entities::UserBasic
      expose :attachments, using: Entities::Attachment
    end

    class OrganizationBasic < Grape::Entity
      expose :id, :name, :parent_id
      expose :avatar do |organization|
        organization.avatar.url
      end
    end

    class ReceiptBasic < Grape::Entity
      expose :id, :read
    end
    class ReceiptAdmin < ReceiptBasic
      expose :read_at
      expose :user, using: Entities::UserBasic
    end
    class Receipt < ReceiptBasic
      expose :organization_ids, :origin
      expose :post, using: Entities::Post
    end

    class Comment < Grape::Entity
      expose :body, :created_at
      expose :user, using: Entities::UserBasic
    end

    class Favorite < Grape::Entity
      expose :id, :created_at, :favoriteable_type, :favoriteable_id
      expose :user, using: Entities::UserBasic
    end

    class Input < Grape::Entity
      expose :id, :_type, :label, :help_text, :required, :identifier, :position
      # text_field
      # text_area
      # number_field
      expose :default_value
      # radio_button
      # check_box
      expose :options
    end

    class Form < Grape::Entity
      expose :id, :title, :created_at
      expose :inputs, using: Entities::Input
    end

  end
end
