class SendSmsToUnreads
  @queue = :youxin_scheduler_queue

  def self.perform(scheduler_id)
    Mongoid.unit_of_work(disable: :all) do
      scheduler = Scheduler::Base.find(scheduler_id)
      return false unless scheduler
      post = scheduler.post
      unread_receipts = post.receipts.unread
      unread_receipts.each do |receipt|
        Notification::Notifier.publish_to_phone(receipt)
      end
      scheduler.ran_at = Time.now
      scheduler.save
    end
  end
end