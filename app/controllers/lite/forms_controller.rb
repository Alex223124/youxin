# encoding: utf-8

class Lite::FormsController < Lite::ApplicationController
  before_filter :ensure_form, only: [:show]
  before_filter :authorize_read_form!, only: [:show]

  def show
    @receipt = @form.post.receipts.where(user_id: current_user.id).first
  end

  private
  def ensure_form
    @form = Form.where(id: params[:id]).first
    raise Youxin::NotFound.new('表单') unless @form
  end

  def authorize_read_form!
    raise Youxin::Forbidden unless current_user_can?(:read, @form)
  end

end
