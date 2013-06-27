module Youxin
  module Entities
    class UserBasic < Grape::Entity
      expose :id, :email, :name, :created_at
      expose :avatar do |user|
        user.avatar.url
      end
    end

    class User < UserBasic
    end

    class UserLogin < UserBasic
      expose :private_token
    end

    class Attachment < Grape::Entity
      expose :id, :file_name, :file_size, :file_type, :image, :url
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

    class FormBasic < Grape::Entity
      expose :id, :title, :created_at
    end
    class Form < FormBasic
      expose :inputs, using: Entities::Input
    end

    class PostBasic < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at
      expose :attachments, using: Entities::Attachment
      expose :forms, using: Entities::FormBasic
    end
    class Post < PostBasic
      expose :author, using: Entities::UserBasic
    end

    class OrganizationBasic < Grape::Entity
      expose :id, :name, :created_at
      expose :avatar do |organization|
        organization.avatar.url
      end
    end

    class ReceiptBasic < Grape::Entity
      expose :id, :read
      expose :favorited do |receipt, options|
        receipt.user.favorites.where(favoriteable_type: 'Receipt',
                                     favoriteable_id: receipt.id).exists? ? true : false
      end
    end
    class ReceiptAdmin < ReceiptBasic
      expose :read_at
      expose :user, using: Entities::UserBasic
    end
    class Receipt < ReceiptBasic
      expose :origin
      expose :organizations, using: Entities::OrganizationBasic
      expose :post, using: Entities::Post
    end
    class ReceiptSimple < ReceiptBasic
      expose :origin
      expose :post, using: Entities::PostBasic
    end

    class ReceiptUser < UserBasic
      expose :receipts do |user, options|
        options[:current_user].receipts.from_users(user.id).count
      end
      expose :unread_receipts do |user, options|
        options[:current_user].receipts.from_users(user.id).unread.count
      end
      expose :last_receipt, using: Entities::ReceiptSimple do |user, options|
        options[:current_user].receipts.from_users(user.id).first
      end
    end

    class AuthorizedOrganization < OrganizationBasic
      expose :parent, using: Entities::OrganizationBasic
    end

    class ReceiptOrganization < OrganizationBasic
      expose :receipts do |organization, options|
        options[:current_user].receipts.from_organizations(organization.id).count
      end
      expose :unread_receipts do |organization, options|
        options[:current_user].receipts.from_organizations(organization.id).unread.count
      end
      expose :last_receipt, using: Entities::ReceiptSimple do |organization, options|
        options[:current_user].receipts.from_organizations(organization.id).first
      end
    end

    class Comment < Grape::Entity
      expose :id, :body, :created_at
      expose :user, using: Entities::UserBasic
    end

    class Favorite < Grape::Entity
      expose :id, :created_at, :favoriteable_type, :favoriteable_id
      expose :user, using: Entities::UserBasic
    end

  end
end
