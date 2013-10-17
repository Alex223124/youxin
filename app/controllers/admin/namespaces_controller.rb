class Admin::NamespacesController < Admin::ApplicationController
  def index
    @namespaces = Namespace.all
  end

  def show
    @namespace = Namespace.where(id: params[:id]).first
  end
end
