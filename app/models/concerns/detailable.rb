# encoding: utf-8

module Detailable
  extend ActiveSupport::Concern

  included do
    field :political_status, type: String # 政治面貌
    field :ethnic, type: String # 民族
    field :birthday, type: String # 出生日期
    field :id_number, type: String # 身份证号码
    field :parental_tel, type: String # 家长联系方式
    field :boc_number, type: String # 中国银行卡号
    field :social_security_number, type: String # 社保卡号
    field :type_of_household, type: String # 家庭户口（城镇或农村）
    field :residential_address, type: String # 家庭住址
    field :zip, type: Integer # 邮政编码
    field :enrollment_region, type: Integer # 生源所在地(省、市、县/区)
    field :poor, type: Boolean, default: false # 是否低保

    attr_accessible :political_status, :ethnic, :birthday, :id_number,
      :parental_tel, :boc_number, :social_security_number, :type_of_household,
      :residential_address, :zip, :enrollment_region, :poor


  end

  POLITICAL_STATUS_OPTIONS = %w(中共党员 中共预备党员 共青团员 群众 民盟盟员
    致公党党员 民建会员 九三学社社员 民进会员 台盟盟员 民革会员 农工党党员 无党派民主人士)
  TYPE_OF_HOUSEHOLD_OPTIONS = %w(城镇 农村)
end
