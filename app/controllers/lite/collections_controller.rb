# encoding: utf-8

class Lite::CollectionsController < ApplicationController
  before_filter :ensure_form, only: [:create]
  before_filter :ensure_blank_collection, only: [:create]

  def create
    entities = params[:collection]
    collection = @form.collections.new(Collection.clean_attributes_with_entities(entities, @form).merge({ user_id: current_user.id }))
    if collection.save
      flash[:notice] = '表单提交成功'
      redirect_to lite_receipt_path(@receipt)
    else
      flash[:error] = "错误：#{collection.errors.full_messages.join(', ')}"
      redirect_to lite_form_path(@form)
    end
  end

  private
  def ensure_form
    @form = Form.where(id: params[:form_id]).first
    raise Youxin::NotFound.new('表单') unless @form
  end
  def ensure_blank_collection
    post = @form.post
    raise Youxin::NotFound.new('优信') unless post

    @receipt = post.receipts.where(user_id: current_user.id).first
    raise Youxin::NotFound.new('优信') unless @receipt

    # raise Youxin::InvalidParameters. new('表单已经提交过了') if @receipt.forms_filled?
  end

end
