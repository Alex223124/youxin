# encoding: utf-8

class CommunicationRecord::Sms
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: String

  validate :receipt, presence: true

  belongs_to :user
  belongs_to :receipt

  before_create do
    return false unless self.receipt
    self.user = self.receipt.author
  end

  MESSAGES = {
    '0'  => '短信发送成功',
    '30' => '密码错误',
    '40' => '账号不存在',
    '41' => '余额不足',
    '42' => '帐号过期',
    '43' => 'IP地址限制',
    '50' => '内容含有敏感词',
    '51' => '手机号码不正确'
  }

  def human_status
    MESSAGES[status]
  end
end
