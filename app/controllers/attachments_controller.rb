class AttachmentsController < ApplicationController
  before_filter do
    @attachment = Attachment::Base.find(params[:id])
    access_denied! unless @attachment && can?(current_user, :download, @attachment)
  end

  def show
    send_file @attachment.storage.path, filename: @attachment.file_name, type: @attachment.file_type, disposition: 'attachment'
  end
end

