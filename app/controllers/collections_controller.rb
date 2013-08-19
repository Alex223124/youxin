# encoding: utf-8

class CollectionsController < ApplicationController
  before_filter :ensure_form, only: [:create, :index, :show]
  before_filter :authorize_write_collection!, only: [:create, :show]
  before_filter :authorize_manage_form!, only: [:index]
  before_filter :ensure_collection, only: [:show]

  def create
    entities = params[:entities]
    collection = @form.collections.new(Collection.clean_attributes_with_entities(entities, @form).merge({ user_id: current_user.id }))
    if collection.save
      render json: collection, status: :created
    else
      render json: collection.errors, status: :unprocessable_entity
    end
  end

  def index
    collections = @form.collections
    render json: collections, each_serializer: CollectionSerializer, root: :collections
  end

  def show
    render json: @collection, serializer: BasicCollectionSerializer, root: :collection
  end

  private
  def ensure_form
    @form = Form.where(id: params[:form_id]).first
    raise Youxin::NotFound.new('表格') unless @form
  end
  def ensure_collection
    @collection = current_user.collections.where(form_id: @form.id).first
    raise Youxin::NotFound.new('collection') unless @collection
  end
  def authorize_manage_form!
    raise Youxin::Forbidden unless current_user_can?(:manage, @form.post)
  end
  def authorize_write_collection!
    raise Youxin::Forbidden unless current_user_can?(:read, @form.post)
  end
end
