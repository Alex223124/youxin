# encoding: utf-8

class CommunicationRecord::Call < CommunicationRecord::Base
  field :call_sid, type: String

  MESSAGES = Hash.new('未知错误').merge(
    Cloopen::REST::Response::STATUS_CODE_DESCRIPTIONS.merge({
      '000000' => '请求成功'
    })
  )

  def human_status
    MESSAGES[status]
  end
end
