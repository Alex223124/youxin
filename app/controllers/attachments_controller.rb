class AttachmentsController < ApplicationController
  before_filter do
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

  def show
    send_file @path, filename: @file_name, type: @file_type, disposition: 'attachment'
  end
end

