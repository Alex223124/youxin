# encoding: utf-8

class CommunicationRecord::Sms < CommunicationRecord::Base
  MESSAGES = Hash.new('未知错误').merge({
    '0'  => '发送成功',
    '30' => '密码错误',
    '40' => '账号不存在',
    '41' => '余额不足',
    '42' => '帐号过期',
    '43' => 'IP地址限制',
    '50' => '内容含有敏感词',
    '51' => '手机号码不正确'
  })


  def human_status
    MESSAGES[status]
  end
end
