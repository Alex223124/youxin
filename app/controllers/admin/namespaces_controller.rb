class Admin::NamespacesController < Admin::ApplicationController
  before_filter :ensure_namespace!, only: [:show]

  def index
    @namespaces = Namespace.all
  end

  def show
  end

  private
  def ensure_namespace!
    @namespace = Namespace.where(id: params[:id]).first
    raise Youxin::NotFound.new('namespace') unless @namespace
  end
end
