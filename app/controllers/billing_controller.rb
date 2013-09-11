# encoding: utf-8

class BillingController < ApplicationController
  def bill_summary
    sms_records = month_filted current_user.sms_communication_records.where(status: '0')
    call_records = month_filted current_user.call_communication_records.where(status: '000000')
    data = {
      date: @start_date.strftime("%Y-%m"),
      sms: sms_records.count,
      call: call_records.count
    }
    render json: { bill_summary: data }
  end
  def sms
    records = date_range_filted current_user.sms_communication_records
    render json: records, each_serializer: BillSerializer, root: :sms_communication_records
  end
  def call
    records = date_range_filted current_user.call_communication_records
    render json: records, each_serializer: BillSerializer, root: :call_communication_records
  end

  private
  def month_filted(communication_records)
    begin
      date = params[:month].blank? ? Time.now.beginning_of_month : "#{params[:month]}-1".to_datetime
    rescue
      raise Youxin::InvalidParameters.new('月份')
    end
    @start_date = date.beginning_of_month
    @end_date = date.end_of_month

    communication_records.gt(created_at: @start_date).lt(created_at: @end_date)
  end
  def date_range_filted(communication_records)
    begin
      start_date = params[:start_date].blank? ? Time.now.beginning_of_week : params[:start_date].to_datetime
      end_date = params[:end_date].blank? ? Time.now.end_of_day : params[:end_date].to_datetime.end_of_day
    rescue
      raise Youxin::InvalidParameters.new('日期')
    end
    communication_records.gt(created_at: start_date).lt(created_at: end_date)
  end
end
