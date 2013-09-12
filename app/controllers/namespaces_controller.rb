class NamespacesController < ApplicationController
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
end
