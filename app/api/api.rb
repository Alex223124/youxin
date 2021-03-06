Dir["#{Rails.root}/app/api/v1/*.rb"].each {|file| require file}

module Youxin
  class API < Grape::API
    prefix 'api'
    version 'v1', using: :path, vendor: :youxin, format: :json

    format :json
    default_error_formatter :json

    rescue_from :all do
      rack_response({'message' => '404 Not found'}.to_json, 404)
    end

    helpers Youxin::APIHelpers

    mount Session
    mount Password
    mount Users
    mount Posts
    mount Attachments
    mount Receipts
    mount Organizations
    mount Forms
    mount Conversations
    mount Notifications
    mount Help
    mount Feedbacks
  end
end
