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
        @conversation = current_user.conversations.where(id: params[:id]).first
        not_found!("conversation") unless @conversation
      end

      get do
        present @conversation, with: Youxin::Entities::Conversation
      end

      delete do
        if current_user == @conversation.originator
          authorize! :manage, @conversation
          @conversation.destroy
        else
          @conversation.remove_user(current_user)
        end
        status(204)
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

      post :participants do
        authorize! :manage, @conversation
        required_attributes! [:participant_ids]
        participants = Array.new
        params[:participant_ids].each do |participant_id|
          participant = User.find(participant_id)
          not_found!("participant with id #{participant_id}") unless participant
          participants << participant
        end
        participants.map { |participant| @conversation.add_user(participant) }
        present @conversation.participants, with: Youxin::Entities::UserBasic
      end

      delete :participants do
        authorize! :manage, @conversation
        required_attributes! [:participant_ids]
        participants = Array.new
        params[:participant_ids].each do |participant_id|
          participant = @conversation.participants.where(id: participant_id).first
          not_found!("participant with id #{participant_id}") unless participant
          participants << participant
        end
        participants.map { |participant| @conversation.remove_user(participant) }
        status(204)
      end
    end
  end
end