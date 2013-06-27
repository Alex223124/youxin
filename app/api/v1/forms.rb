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
    end
  end

end