class Notifications < Grape::API
  before { authenticate! }

  resource :notifications do
    put :read do
      notifications = current_user.notifications.where(:id.in => params[:notification_ids])
      notifications.map { |notification| notification.read! }
      status(204)
    end

    route_param :id do
      before do
        @notification = current_user.notifications.where(id: params[:id]).first
        not_found!("notification with id #{params[:id]}") unless @notification
      end
      put :read do
        @notification.read!
        status(204)
      end
    end
  end

end
