# encoding: utf-8

class SendSmsToUnfilledsJob
  @queue = :youxin_scheduler_queue

  def self.perform(post_id)
    Mongoid.unit_of_work(disable: :all) do
      post = Post.where(id: post_id).first
      return false unless post
      form = post.forms.first
      return false unless form
      content = "【#{post.title}】 有表单需要您请尽快填写。"
      content = "#{post.author.name}: #{content[0..35]}...【combee.co】"

      unfilled_receipts = post.receipts.unfilled
      unfilled_receipts.each do |receipt|
        Notification::Notifier.message(receipt.user.phone, content) if receipt.user.phone?
      end
    end
  end
end