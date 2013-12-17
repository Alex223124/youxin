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

      def publish_message_to_ios_device_async(message_id)
        ::Resque.enqueue(PublishMessageToIosDeviceJob, message_id)
      end

      def make_landing_call_to_phone_async(receipt_ids)
        ::Resque.enqueue(MakeLandingCallToPhoneJob, receipt_ids)
      end

      def send_welcome_message_async(user_id)
        ::Resque.enqueue(SendWelcomeMessageJob, user_id)
      end
      def baidu_push_post_to_android_async(post_id)
        ::Resque.enqueue(BaiduPushPostToAndroidJob, post_id)
      end
      def baidu_push_message_to_android_async(message_id)
        ::Resque.enqueue(BaiduPushMessageToAndroidJob, message_id)
      end
      def baidu_push_comment_to_android_async(comment_notification_id)
        ::Resque.enqueue(BaiduPushCommentToAndroidJob, comment_notification_id)
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end
