class Feedbacks < Grape::API
  before { authenticate! }

  resource :feedbacks do
    post do
      required_attributes! [:body]

      attrs = attributes_for_keys [:category, :body, :contact, :devise, :version_code, :version_name]
      feedback = current_user.feedbacks.new attrs

      if feedback.save
        present feedback, with: Youxin::Entities::Feedback
      else
        fail!(feedback)
      end
    end
  end
end
