class MakeCallsToUnreadsJob
  @queue = :youxin_scheduler_queue

  def self.perform(scheduler_id)
    Mongoid.unit_of_work(disable: :all) do
      scheduler = Scheduler::Call.where(id: scheduler_id).first
      return false unless scheduler
      post = scheduler.post
      unread_receipts = post.receipts.unread
      unread_receipts.each do |receipt|
        Notification::Notifier.make_landing_call_to_phone(receipt)
      end
      scheduler.ran_at = Time.now
      scheduler.save
    end
  end
end