module Notification
  module Backend
    module ClassMethods
      def publish_to_phone_async(receipt)
        ::Resque.enqueue(PublishToPhoneJob, receipt)
      end
      def publish_to_faye_client_async(users, data)
        ::Resque.enqueue(PublishToFayeClientJob, users, data)
      end
      def publish_to_ios_device_async(users, data)
        ::Resque.enqueue(PublishToIosDeviceJob, users, data)
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end