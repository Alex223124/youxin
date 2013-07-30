module Youxin
  module Entities
    class UserSimple < Grape::Entity
      expose :id, :name
      expose :avatar do |user|
        user.avatar.url
      end
    end

    class UserBasic < UserSimple
      expose :email, :created_at
    end

    class UserProfile < UserBasic
      expose :bio, :gender, :qq, :blog, :uid
      expose :header do |user|
        user.header.url
      end
    end

    class UserWithNotifications < Grape::Entity
      expose :notification_channel
      expose :notifications do |user|
        {
          comment_notifications: user.comment_notifications.unread.count,
          organization_notifications: user.organization_notifications.unread.count,
          message_notifications: user.message_notifications.unread.count
        }
      end
    end

    class UserLogin < UserBasic
      expose :private_token
    end

    class AuthorizedUser < UserSimple
      expose :actions do |user, options|
        options[:organization].user_actions_organization_relationships.where(user_id: user.id).first.try(:actions)
      end
    end

    class Attachment < Grape::Entity
      expose :id, :file_name, :file_size, :file_type, :image, :url
    end

    class Option < Grape::Entity
      expose :id, :default_selected, :value
    end

    class Input < Grape::Entity
      expose :id, :_type, :label, :help_text, :required, :identifier, :position
      # text_field
      # text_area
      # number_field
      expose :default_value
      # radio_button
      # check_box
      expose :options, using: Entities::Option
      # all
    end

    class Entity < Grape::Entity
      expose :key, :value
    end

    class Collection < Grape::Entity
      expose :created_at
      expose :entities, using: Entities::Entity
    end

    class FormBasic < Grape::Entity
      expose :id, :title, :created_at
    end
    class Form < FormBasic
      expose :inputs, using: Entities::Input
    end

    class PostSimple < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at    
    end
    class PostBasic < PostSimple
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

    class OrganizationWithAuthorizedUsers < OrganizationBasic
      expose :bio
      expose :authorized_users, using: Entities::UserSimple
    end
    class OrganizationWithAuthorizedUsersAndProfile < OrganizationWithAuthorizedUsers
      expose :header do |organization|
        organization.header.url
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
        options[:current_user].receipts.from_user(user).count
      end
      expose :unread_receipts do |user, options|
        options[:current_user].receipts.from_user(user).unread.count
      end
      expose :last_receipt, using: Entities::ReceiptSimple do |user, options|
        options[:current_user].receipts.from_user(user).first
      end
    end

    class AuthorizedOrganization < OrganizationBasic
      expose :parent_id
      expose :members do |organization, options|
        organization.members.count
      end
    end

    class ReceiptOrganization < OrganizationBasic
      expose :receipts do |organization, options|
        options[:current_user].receipts.from_organization(organization).count
      end
      expose :unread_receipts do |organization, options|
        options[:current_user].receipts.from_organization(organization).unread.count
      end
      expose :last_receipt, using: Entities::ReceiptSimple do |organization, options|
        options[:current_user].receipts.from_organization(organization).first
      end
    end

    class Commentable < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at    
    end
    class Comment < Grape::Entity
      expose :id, :body, :created_at
      expose :user, using: Entities::UserBasic
    end
    class CommentWithCommentable < Comment
      expose :commentable_type
      expose :commentable, using: Entities::Commentable
    end

    class Favorite < Grape::Entity
      expose :id, :created_at, :favoriteable_type, :favoriteable_id
      expose :user, using: Entities::UserBasic
    end

    class Message <  Grape::Entity
      expose :id, :created_at, :body, :conversation_id
      expose :user, using: Entities::UserBasic
    end

    class ConversationBasic < Grape::Entity
      expose :id, :created_at, :updated_at
    end

    class MessageWithConversation < Grape::Entity
      expose :id, :created_at, :body
      expose :conversation, using: Entities::ConversationBasic
      expose :user, using: Entities::UserBasic
    end

    class Conversation < Grape::Entity
      expose :id, :created_at, :updated_at
      expose :last_message, using: Entities::Message
      expose :originator, using: Entities::UserBasic
      expose :participants, using: Entities::UserBasic
    end

    class Notification < Grape::Entity
      # common
      expose :id, :created_at, :read
      expose :_type, as: :notificationable_type
      # comment
      expose :comment, as: :notificationable, using: Entities::CommentWithCommentable
      # message
      expose :message, as: :notificationable, using: Entities::MessageWithConversation
      # organization
      expose :organization, as: :notificationable, using: Entities::OrganizationBasic
      expose :status
    end
    class SmsScheduler < Grape::Entity
      expose :delayed_at, :ran_at
    end
  end
end
