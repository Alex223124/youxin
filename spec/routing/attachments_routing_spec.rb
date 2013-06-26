require 'spec_helper'

describe AttachmentsController do
  it "to #show" do
    get('/attachments/123').should route_to('attachments#show', id: '123')
  end
end
