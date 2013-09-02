class MakeLandingCallToPhoneJob
  @queue = :youxin_notification_queue

  def self.perform(receipt_ids)
    receipt_ids.each do |receipt_id|
      Notification::Notifier.make_landing_call_to_phone(receipt_id)
    end
  end

end