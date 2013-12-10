class Admin::UsersController < Admin::ApplicationController
  before_filter :ensuere_user!

  def show
    @posts = @user.posts
  end

  private
  def ensuere_user!
    @user = User.where(id: params[:id]).first
    raise Youxin::NotFound.new('user') unless @user
  end
end
