# encoding: utf-8

class CommentsController < ApplicationController
  before_filter :ensure_post!, only: [:index, :create]
  before_filter :authorized_read_post!, only: [:index, :create]
  def index
    comments = @post.comments
    render json: comments, each_serializer: CommentSerializer, root: :comments
  end

  def create
    params[:comment][:user_id] = current_user.id
    comment = @post.comments.new(params[:comment])
    if comment.save
      render json: comment, status: :created
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end

  private
  def ensure_post!
    @post = Post.where(id: params[:post_id]).first
    raise Youxin::NotFound.new('优信') unless @post
  end
  def authorized_read_post!
    raise Youxin::Forbidden unless current_user_can?(:read, @post)
  end
end
