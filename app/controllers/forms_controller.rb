# encoding: utf-8

class FormsController < ApplicationController
  before_filter :authorize_create_form!, only: [:create]
  before_filter :ensure_form, only: [:get_collection, :download]
  before_filter :authorize_manage_form!, only: [:download]

  def create
    form_data = params[:form]
    attr = Form.clean_attributes_with_inputs(form_data)
    form = current_user.forms.new(attr)
    if form.save
      render json: form, serializer: BasicFormSerializer, root: :form
    else
      render json: form.errors, status: :unprocessable_entity
    end
  end

  def download
    file = @form.archive
    send_file file.path, filename: "#{@form.title}.xls", type: 'application/vnd.ms-excel; charset=utf-8', disposition: 'attachment'
  end

  private
  def ensure_form
    @form = Form.where(id: params[:id]).first
    raise Youxin::NotFound.new('表格') unless @form
  end
  def authorize_create_form!
    raise Youxin::Forbidden if current_user.authorized_organizations.count.zero?
  end
  def authorize_manage_form!
    raise Youxin::Forbidden unless current_user_can?(:manage, @form.post)
  end
end
