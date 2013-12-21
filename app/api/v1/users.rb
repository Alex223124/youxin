class Users < Grape::API
  before { authenticate! }

  resource :user do
    desc 'Get the info of current user.'
    get do
      present current_user, with: Youxin::Entities::UserProfile
    end

    put do
      attrs = attributes_for_keys [:avatar, :header, :phone, :name, :bio, :gender, :qq, :blog, :uid, :email]
      if current_user.update_attributes attrs
        status(204)
      else
        fail!(current_user.errors)
      end
    end

    desc 'Get organizations which the user have the authorization in.'
    get 'authorized_organizations' do
      actions = attributes_for_keys([:actions])[:actions]
      if actions
        actions = actions.map(&:to_sym)
        authorized_organizations = []
        relationships = current_user.user_actions_organization_relationships
        relationships.each do |relationship|
          authorized_organizations << relationship.organization if actions - relationship.actions == []
        end
      else
        authorized_organizations = current_user.authorized_organizations
      end

      present authorized_organizations, with: Youxin::Entities::Organization
    end

    desc 'Get recent organizations who have sent post to user'
    get 'receipt_organizations' do
      receipt_organizations = current_user.receipt_organizations
      present receipt_organizations, with: Youxin::Entities::ReceiptOrganization, current_user: current_user
    end

    desc 'Get recent contacts who have sent post to user'
    get 'receipt_users' do
      receipt_users = current_user.receipt_users
      present receipt_users, with: Youxin::Entities::ReceiptUser, current_user: current_user
    end

    desc 'Get all the receipts.'
    get 'receipts' do
      receipts = paginate current_user.receipts
      present receipts, with: Youxin::Entities::Receipt
    end
    desc 'Get all the unread receipts.'
    get 'unread_receipts' do
      receipts = paginate current_user.receipts.unread
      present receipts, with: Youxin::Entities::Receipt
    end

    desc 'Get all the favorite receipts'
    get 'favorite_receipts' do
      receipts = paginate(current_user.favorites.receipts).map(&:favoriteable)
      present receipts, with: Youxin::Entities::Receipt
    end

    desc 'Create ios_device_token to user'
    post 'ios_device_token' do
      current_user.push_ios_device_token params[:device_token]
      if current_user.errors.empty?
        status(204)
      else
        fail!(current_user.errors)
      end
    end

    desc 'Delete ios_device_token of user'
    delete 'ios_device_token' do
      current_user.pull_ios_device_token params[:device_token]
      if current_user.errors.empty?
        status(204)
      else
        fail!(current_user.errors)
      end
    end

    get 'conversations' do
      present current_user.conversations, with: Youxin::Entities::Conversation
    end

    get 'notifications' do
      current_user.ensure_notification_channel!
      present current_user, with: Youxin::Entities::UserWithNotifications
    end
    get 'notifications_timeline' do
      notifications = paginate current_user.notifications
      present notifications, with: Youxin::Entities::Notification
    end
    get 'notifications_timeline/unread' do
      notifications = paginate current_user.notifications.unread
      present notifications, with: Youxin::Entities::Notification
    end

    %w{comment organization message}.each do |notificationable|
      notificationables = "#{notificationable}_notifications"
      get notificationables do
        notifications = paginate current_user.send notificationables
        present notifications, with: Youxin::Entities::Notification
      end
      get "#{notificationables}/unread" do
        notifications = paginate current_user.send(notificationables).unread
        present notifications, with: Youxin::Entities::Notification
      end
    end

    post :binds do
      required_attributes! [:baidu_user_id, :baidu_channel_id]
      attrs = attributes_for_keys [:baidu_user_id, :baidu_channel_id]

      bind = Bind.where(baidu_user_id: attrs[:baidu_user_id],
                        baidu_channel_id: attrs[:baidu_channel_id]).first

      if bind && bind.user == current_user
        present bind, with: Youxin::Entities::Bind
      else
        bind.destroy if bind

        bind = current_user.binds.new attrs
        if bind.save
          present bind, with: Youxin::Entities::Bind
        else
          fail!(bind.errors)
        end
      end
    end
    delete :binds do
      attrs = attributes_for_keys [:baidu_user_id, :baidu_channel_id]

      bind = current_user.binds.where(baidu_user_id: attrs[:baidu_user_id],
                                      baidu_channel_id: attrs[:baidu_channel_id]).first
      if bind
        bind.destroy
        status(204)
      else
        not_found!('bind')
      end
    end
    delete 'binds/:bind_id' do
      required_attributes! [:bind_id]

      bind = current_user.binds.where(id: params[:bind_id]).first
      if bind
        bind.destroy
        status(204)
      else
        not_found!('bind')
      end
    end
  end

  resource :users do
    route_param :id do
      before do
        @user = current_namespace.users.find(params[:id])
        not_found! unless @user
      end
      get do
        if current_user_can? :read_profile, @user
          present @user, with: Youxin::Entities::UserProfile
        else
          present @user, with: Youxin::Entities::OtherUserProfile
        end
      end
      get 'organizations' do
        organizations = @user.organizations
        present organizations, with: Youxin::Entities::Organization
      end
      get 'receipts' do
        receipts = paginate current_user.receipts.from_user(@user)
        present receipts, with: Youxin::Entities::Receipt
      end
      get 'unread_receipts' do
        unread_receipts = paginate current_user.receipts.from_user(@user).unread
        present unread_receipts, with: Youxin::Entities::Receipt
      end
    end
  end

end
