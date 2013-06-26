class Attachments < Grape::API
  before { authenticate! }

  resource :attachments do
    post do
      authenticated_as_attachmentable
      required_attributes! [:file]

      file = attributes_for_keys([:file])[:file]

      attachment = current_user.image_attachments.new storage: file
      attachment = current_user.file_attachments.new storage: file unless attachment.valid?

      if attachment.save
        present attachment, with: Youxin::Entities::Attachment
      else
        fail!(attachment.errors)
      end
    end

  end
end