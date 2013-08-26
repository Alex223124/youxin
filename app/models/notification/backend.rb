module Notification
  module Backend
    module ClassMethods
      def publish_to_phone_async(receipt_id)
        ::Resque.enqueue(PublishToPhoneJob, receipt_id)
      end
      def publish_to_faye_client_async(user_ids, data)
        ::Resque.enqueue(PublishToFayeClientJob, user_ids, data)
      end
      def publish_to_ios_device_async(user_ids, data)
        ::Resque.enqueue(PublishToIosDeviceJob, user_ids, data)
      end
      def publish_post_to_ios_device_async(post_id)
        ::Resque.enqueue(PublishPostToIosDeviceJob, post_id)
      end
      def publish_post_to_faye_client_async(post_id)
        ::Resque.enqueue(PublishPostToFayeClientJob, post_id)
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end