class PostsController < ApplicationController
  before_filter :ensure_post
  def unread_receipts
    access_denied! unless can?(current_user, :manage, @post)
    unread_receipts = @post.receipts.unread
    render json: unread_receipts, each_serializer: ReceiptAdminSerializer, root: :unread_receipts
  end

  def comments
    access_denied! unless can?(current_user, :read, @post)
    comments = @post.comments
    render json: comments, each_serializer: CommentSerializer, root: :comments
  end

  private
  def ensure_post
    @post = Post.find(params[:id])
  end
end