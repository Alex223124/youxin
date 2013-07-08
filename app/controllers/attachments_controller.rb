class AttachmentsController < ApplicationController
  before_filter :prepare_attachment, only: [:show]
  before_filter :prepare_post, only: [:index]

  def index
    render json: @post.attachments, each_serializer: AttachmentSerializer
  end

  def show
    send_file @path, filename: @file_name, type: @file_type, disposition: 'attachment'
  end

  private
  def prepare_attachment
    @attachment = Attachment::Base.find(params[:id])
    unless @attachment && can?(current_user, :download, @attachment)
      access_denied!
      return false
    end
    if @attachment.image? && params['version'].present?
      begin
        @path = @attachment.storage.send(params['version']).path
      rescue => e
        access_denied!
        return false
      end
      @file_name = "#{params['version']}_#{@attachment.file_name}"
    else
      @path = @attachment.storage.path
      @file_name = @attachment.file_name
    end
    @file_type = @attachment.file_type
  end

  def prepare_post
    @post = Post.find(params[:post_id])
    unless @post && can?(current_user, :read, @post)
      access_denied!
      return false
    end
  end
end
