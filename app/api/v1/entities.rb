module Youxin
  module Entities
    class YouxinEntity < Grape::Entity
      class << self
        def abilities
          @abilities ||= begin
                           abilities = Six.new
                           abilities << ::UserActionsOrganizationRelationship
                           abilities << ::Post
                           abilities << ::Attachment::Base
                           abilities << ::Conversation
                           abilities << ::Form
                           abilities << ::Namespace
                           abilities << ::User
                           abilities
                         end
        end
        def can?(object, action, subject)
          abilities.allowed?(object, action, subject)
        end
      end
    end

    class Bind < YouxinEntity
      expose :id, :baidu_user_id, :baidu_channel_id
    end

    class UserSimple < YouxinEntity
      expose :id, :name, :email, :created_at
      expose :avatar do |user|
        user.avatar.url
      end
    end

    class UserBasic < UserSimple
      expose :phone
    end

    class UserProfile < UserSimple
      expose :bio, :gender, :qq, :blog, :uid, :created_at
      expose :header do |user|
        user.header.url
      end
      expose :phone do |user, options|
        can?(options[:current_user], :read_profile, user) ? user.phone : nil
      end
    end

    class User < UserBasic
      expose :bio, :gender, :qq, :blog, :uid
    end

    class UserWithNotifications < YouxinEntity
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

    class AuthorizedUser < UserBasic
      expose :actions do |user, options|
        options[:organization].user_actions_organization_relationships.where(user_id: user.id).first.try(:actions)
      end
    end

    class Attachment < YouxinEntity
      expose :id, :file_name, :file_size, :file_type, :image, :url
    end

    class Option < YouxinEntity
      expose :id, :default_selected, :value
    end

    class Input < YouxinEntity
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

    class Entity < YouxinEntity
      expose :key, :value
    end

    class Collection < YouxinEntity
      expose :created_at
      expose :entities, using: Entities::Entity
    end

    class FormBasic < YouxinEntity
      expose :id, :title, :created_at
    end
    class Form < FormBasic
      expose :inputs, using: Entities::Input
    end

    class PostSimple < YouxinEntity
      expose :id, :title, :body, :body_html, :created_at
    end
    class PostBasic < PostSimple
      expose :attachments, using: Entities::Attachment
      expose :forms, using: Entities::FormBasic
    end
    class Post < PostBasic
      expose :author, using: Entities::UserBasic
    end

    class OrganizationBasic < YouxinEntity
      expose :id, :name, :created_at
      expose :avatar do |organization|
        organization.avatar.url
      end
    end

    class Organization < OrganizationBasic
      expose :parent_id
      expose :members do |organization, options|
        organization.member_ids.count
      end
    end
    class OrganizationWithProfile < Organization
      expose :bio
      expose :header do |organization|
        organization.header.url
      end
      expose :joined_at do |organization, options|
        options[:current_user].user_organization_position_relationships.where(organization_id: organization.id).first.try(:created_at)
      end
    end

    class ReceiptBasic < YouxinEntity
      expose :id, :read, :archived
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

    class Commentable < YouxinEntity
      expose :id, :title, :body, :body_html, :created_at
    end
    class Comment < YouxinEntity
      expose :id, :body, :created_at
      expose :user, using: Entities::UserSimple
    end
    class CommentWithCommentable < Comment
      expose :commentable_type
      expose :commentable, using: Entities::Commentable
    end

    class Favorite < YouxinEntity
      expose :id, :created_at, :favoriteable_type, :favoriteable_id
      expose :user, using: Entities::UserBasic
    end

    class Message <  Entity
      expose :id, :created_at, :body, :conversation_id
      expose :user, using: Entities::UserBasic
    end

    class ConversationBasic < YouxinEntity
      expose :id, :created_at, :updated_at
    end

    class MessageWithConversation < YouxinEntity
      expose :id, :created_at, :body
      expose :conversation, using: Entities::ConversationBasic
      expose :user, using: Entities::UserBasic
    end

    class Conversation < YouxinEntity
      expose :id, :created_at, :updated_at
      expose :last_message, using: Entities::Message
      expose :originator, using: Entities::UserBasic
      expose :participants, using: Entities::UserBasic
    end

    class Notification < YouxinEntity
      # common
      expose :id, :created_at, :read
      expose :_type, as: :notificationable_type
      # comment
      expose :comment, as: :notificationable, using: Entities::CommentWithCommentable
      # message
      expose :message, as: :notificationable, using: Entities::MessageWithConversation
      # organization
      expose :organization, as: :notificationable, using: Entities::OrganizationBasic
      # mentionable
      expose :mentionable, as: :notificationable, using: Entities::CommentWithCommentable
      expose :status
    end
    class Scheduler < YouxinEntity
      expose :delayed_at, :ran_at
    end

    class Feedback < YouxinEntity
      expose :category, :body, :contact, :devise, :version_code, :version_name
      expose :user, using: Entities::UserSimple
    end
  end
end
