class Admin::UsersController < Admin::ApplicationController
  before_filter :ensuere_namespace!
  before_filter :ensuere_user!

  def show
    @posts = @user.posts
  end

  private
  def ensuere_namespace!
    @namespace = Namespace.where(id: params[:namespace_id]).first
    raise Youxin::NotFound.new unless @namespace
  end

  def ensuere_user!
    @user = @namespace.users.where(id: params[:id]).first
    raise Youxin::NotFound.new unless @user
  end
end
