class Forms < Grape::API
  before { authenticate! }

  resource :forms do
    route_param :id do
      before do
        @form = Form.find(params[:id])
        not_found!("form") unless @form
        authorize! :read, @form.post
      end
      get do
        present @form, with: Youxin::Entities::Form
      end
      post 'collection' do
        fail! if @form.collections.where(user_id: current_user.id).present?
        @entities = params[:entities]
        @collection = @form.collections.new(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: current_user.id }))
        if @collection.save
          present @collection, with: Youxin::Entities::Collection, current_user: current_user
        else
          fail!(@collection.errors)
        end
      end
      get 'collections' do
        authorize! :manage, @form.post
        @collections = @form.collections
        present @collections, with: Youxin::Entities::Collection, current_user: current_user
      end
      get 'collection' do
        @collection = current_user.collections.find_by(form_id: @form.id)
        if @collection
          present @collection, with: Youxin::Entities::Collection, current_user: current_user
        else
          status(204)
        end
      end
    end
  end

end
