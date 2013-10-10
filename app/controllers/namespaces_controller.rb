class NamespacesController < ApplicationController
  before_filter :authorize_manage_namespace!, only: [:update]

  def show
    render json: current_namespace, serializer: NamespaceSerializer, root: :namespace
  end
  def update
    if current_namespace.update_attributes params[:namespace]
      render json: current_namespace, serializer: NamespaceSerializer, root: :namespace
    else
      render json: current_namespace.errors, status: :unprocessable_entity
    end
  end

  private
  def authorize_manage_namespace!
    raise Youxin::Forbidden.new('系统') unless current_user_can?(:manage_namespace, current_namespace)
  end

end
