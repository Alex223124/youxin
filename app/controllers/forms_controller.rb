class FormsController < ApplicationController
  before_filter :ensure_form, only: [:create_collection, :get_collection, :collections]
  before_filter :check_collection, only: [:get_collection]
  before_filter :authorize_manage_form, only: [:collections]
  def create
    form_data = params[:form]
    if form_data.blank? || form_data[:inputs].blank? || form_data[:inputs].size.zero?
      render json: { inputs: 'zero' }, status: 400
      return
    end
    attr = Form.clean_attributes_with_inputs(form_data)
    form = current_user.forms.new(attr)
    if form.save
      render json: form, serializer: BasicFormSerializer, root: :form
    else
      render json: form.errors, status: 400
    end
  end
  def collections
    collections = @form.collections
    render json: collections, each_serializer: CollectionSerializer, root: :collections
  end
  def create_collection
    @entities = params[:entities]
    @collection = @form.collections.new(Collection.clean_attributes_with_entities(@entities, @form).merge({ user_id: current_user.id }))
    if @collection.save
      render json: @entities, status: :created
    else
      render json: @collection.errors, status: :unprocessable_entity
    end
  end
  def get_collection
    render json: { collection: @collection.entities.as_json(only: [:key, :value]) }
  end

  private
  def ensure_form
    @form = Form.find(params[:id])
    return not_found! unless @form
  end
  def check_collection
    @collection = current_user.collections.find_by(form_id: @form.id)
    return bad_request! unless @collection
  end
  def authorize_manage_form
    return access_denied! unless can?(current_user, :manage, @form.post)
  end
end
