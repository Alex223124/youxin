# encoding: utf-8

class MakeCallsToUnfilledsJob
  @queue = :youxin_scheduler_queue

  def self.perform(post_id)
    Mongoid.unit_of_work(disable: :all) do
      post = Post.where(id: post_id).first
      return false unless post
      form = post.forms.first
      return false unless form
      content = "您好！您收到了#{post.author.name}通过combee给您的电话留言：您有一条优信，#{post.title}，需要填写表单，请尽快登陆combee网站或移动客户端填写。留言已结束，感谢您的收听，再见。"

      unfilled_receipts = post.receipts.unfilled
      unfilled_receipts.each do |receipt|
        Notification::Notifier.call(receipt.user.phone, media_txt: content) if receipt.user.phone?
      end
    end
  end
end