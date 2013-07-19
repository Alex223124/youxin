class Conversations < Grape::API
  before { authenticate! }

  resource :conversations do
    post do
      required_attributes! [:participant_ids]
      participants = Array.new
      params[:participant_ids].each do |participant_id|
        participant = User.find(participant_id)
        not_found!("participant with id #{participant_id}") unless participant
        participants << participant
      end
      conversation = current_user.send_message_to(participants)
      if conversation
        present conversation, with: Youxin::Entities::Conversation
      else
        fail!
      end
    end
    route_param :id do
      before do
        @conversation = Conversation.find(params[:id])
        not_found!("conversation") unless @conversation
        authorize! :read, @conversation
      end

      get do
        present @conversation, with: Youxin::Entities::Conversation
      end

      get :messages do
        messages = paginate @conversation.messages
        present messages, with: Youxin::Entities::Message
      end

      post :messages do
        required_attributes! [:body]
        message = current_user.messages.new(conversation_id: @conversation.id, body: params[:body])
        if message.save
          present message, with: Youxin::Entities::Message
        else
          fail!(message.errors)
        end
      end
    end
  end
end