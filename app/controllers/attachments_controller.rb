class AttachmentsController < ApplicationController
  before_filter :prepare_attachment, only: [:show]
  before_filter :ensure_post!, only: [:index]
  before_filter :authorize_read_post!, only: [:index]
  before_filter :authorize_create_attachments!, only: [:create]

  def index
    render json: @post.attachments, each_serializer: AttachmentSerializer, root: :attachments
  end

  def show
    send_file @path, filename: @file_name, type: @file_type, disposition: 'attachment'
  end

  def create
    attachment = current_user.image_attachments.new storage: params[:file]
    attachment = current_user.file_attachments.new storage: params[:file] unless attachment.valid?

    if attachment.save
      render json: attachment, status: :created, serializer: AttachmentSerializer, root: :attachment
    else
      render json: attachment.errors, status: :unprocessable_entity
    end
  end

  private
  def prepare_attachment
    @attachment = Attachment::Base.find(params[:id])
    raise Youxin::NotFound unless @attachment
    raise Youxin::Forbidden unless can?(current_user, :download, @attachment)

    if @attachment.image? and params['version'].present?
      begin
        @path = @attachment.storage.send(params['version']).path
      rescue
        raise Youxin::NotFound
      end
      @file_name = "#{params['version']}_#{@attachment.file_name}"
    else
      @path = @attachment.storage.path
      @file_name = @attachment.file_name
    end
    @file_type = @attachment.file_type
  end
  def ensure_post!
    @post = Post.where(id: params[:post_id]).first
    raise Youxin::NotFound unless @post
  end
  def authorize_read_post!
    raise Youxin::Forbidden unless current_user_can?(:read, @post)
  end
  def authorize_create_attachments!
    raise Youxin::Forbidden if current_user.authorized_organizations.count.zero?
  end
end
