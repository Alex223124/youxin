class Scheduler::Call < Scheduler::Base
  after_create do
    Resque.enqueue_at(self.delayed_at, MakeCallsToUnreadsJob, self.id)
  end
  after_destroy do
    remove_delayed
  end

  def run_now!
    enqueue_at(Time.now)
  end

  private
  def enqueue_at(timestamp)
    remove_delayed
    self.delayed_at = timestamp
    self.save
    Resque.enqueue_at(self.delayed_at, MakeCallsToUnreadsJob, self.id)
  end
  def remove_delayed
    Resque.remove_delayed(MakeCallsToUnreadsJob, self.id)
  end
end
