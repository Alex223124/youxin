# encoding: utf-8

class SendSmsToUnfilledsJob
  @queue = :youxin_scheduler_queue

  def self.perform(post_id)
    Mongoid.unit_of_work(disable: :all) do
      post = Post.where(id: post_id).first
      return false unless post
      form = post.forms.first
      return false unless form
      content = "#{post.author.name}: 请填写#{form.title}"

      unfilled_receipts = post.receipts.unfilled
      unfilled_receipts.each do |receipt|
        message_content = "#{content}，详情点击： #{receipt.short_url} 【Combee】"
        Notification::Notifier.message(receipt.user.phone, message_content) if receipt.user.phone?
      end
    end
  end
end
