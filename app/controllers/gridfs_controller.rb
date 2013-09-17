class GridfsController < ApplicationController
  skip_before_filter :authenticate_user!
  def serve
    gridfs_path = env["PATH_INFO"]
    begin
      gridfs_file = Mongoid::GridFS[gridfs_path]
      self.response_body = gridfs_file.data
      self.content_type = gridfs_file.content_type
      headers["Content-Length"] = gridfs_file.length.to_s
    rescue
      self.status = :file_not_found
      self.content_type = 'text/plain'
      self.response_body = ''
    end
  end
end
