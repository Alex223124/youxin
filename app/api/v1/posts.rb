class Posts < Grape::API
  before { authenticate! }

  resource :posts do
    desc "Create a post."
    post do
      bulk_authorize! :create_youxin, current_namespace.organizations.where(:id.in => params[:organization_ids])
      required_attributes! [:body_html, :organization_ids]

      attrs = attributes_for_keys [:title, :body_html, :organization_ids, :attachment_ids, :delayed_sms_at]
      attachment_ids = attrs.delete(:attachment_ids)
      delayed_sms_at = attrs.delete(:delayed_sms_at).to_i
      post = current_user.posts.new attrs

      attachments = []
      attachment_ids.each do |attachment_id|
        attachment = Attachment::Base.find(attachment_id)

        not_found!("attachment") unless attachment
        authorize! :manage, attachment

        if attachment.post_id.present?
          post.errors.add :attachment_ids, :inclusion
          fail!(post.errors)
        end
        attachments |= [attachment]
      end if attachment_ids
      if post.save
        attachments.map { |attachment| post.attachments << attachment } if attachments.present?
        post.sms_schedulers.create delayed_at: Time.at(delayed_sms_at) unless delayed_sms_at.zero?
        present post, with: Youxin::Entities::Post
      else
        fail!(post.errors)
      end
    end

    route_param :id do
      before do
        @post = Post.find(params[:id])
        not_found!("post") unless @post
        authorize! :read, @post
      end
      get do
        present @post, with: Youxin::Entities::Post
      end
      get 'forms' do
        @forms = @post.forms
        present @forms, with: Youxin::Entities::Form
      end
      get 'receipts' do
        authorize! :manage, @post
        receipts = @post.receipts.all
        present receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'unread_receipts' do
        authorize! :manage, @post
        unread_receipts = @post.receipts.unread
        present unread_receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'read_receipts' do
        authorize! :manage, @post
        read_receipts = @post.receipts.read
        present read_receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'comments' do
        authorize! :read, @post
        comments = paginate @post.comments
        present comments, with: Youxin::Entities::Comment
      end
      post 'comments' do
        authorize! :read, @post
        required_attributes! [:body]
        attrs = attributes_for_keys [:body]
        attrs.merge!({ user_id: current_user.id })
        comment = @post.comments.new attrs
        if comment.save
          present comment, with: Youxin::Entities::Comment
        else
          fail!(comment.errors)
        end
      end
      post :sms_notifications do
        authorize! :manage, @post
        scheduler = @post.sms_schedulers.where(ran_at: nil).first
        if scheduler
          scheduler.run_now!
        else
          @post.sms_schedulers.create delayed_at: Time.now
        end
        status(204)
      end
      get :sms_scheduler do
        authorize! :manage, @post
        sms_scheduler = @post.sms_schedulers.where(ran_at: nil).first || @post.sms_schedulers.first
        present sms_scheduler, with: Youxin::Entities::Scheduler
      end
      post :call_notifications do
        authorize! :manage, @post
        scheduler = @post.call_schedulers.where(ran_at: nil).first
        if scheduler
          scheduler.run_now!
        else
          @post.call_schedulers.create delayed_at: Time.now
        end
        status(204)
      end
      get :call_scheduler do
        authorize! :manage, @post
        call_scheduler = @post.call_schedulers.where(ran_at: nil).first || @post.call_schedulers.first
        present call_scheduler, with: Youxin::Entities::Scheduler
      end
      # TODO: need delete next version
      post :phone_notifications do
        authorize! :manage, @post
        scheduler = @post.call_schedulers.where(ran_at: nil).first
        if scheduler
          scheduler.run_now!
        else
          @post.call_schedulers.create delayed_at: Time.now
        end
        status(204)
      end
      get :phone_scheduler do
        authorize! :manage, @post
        call_scheduler = @post.call_schedulers.where(ran_at: nil).first || @post.call_schedulers.first
        present call_scheduler, with: Youxin::Entities::Scheduler
      end
    end
  end
end
