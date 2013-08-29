# encoding: utf-8

module SmsRecoverable
  extend ActiveSupport::Concern
  # TODO: no_test

  def reset_password_by_sms!(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation

    if valid?
      clear_reset_sms_token
    end

    save
  end

  def send_reset_sms
    generate_reset_sms_token! if should_generate_reset_sms_token?
    send_sms_notification
  end

  def reset_sms_period_valid?
    reset_sms_sent_at && reset_sms_sent_at.utc >= Youxin.config.devise.reset_sms_token_within.minutes.ago
  end

  protected

  def send_sms_notification
    content = "Combee 验证码为：#{reset_sms_token}（请在#{Youxin.config.devise.reset_sms_token_within}分钟内完成验证，如已成功启用，请忽略此短信）【Combee.co】"
    ChinaSMS.to(phone, content)
  end

  def should_generate_reset_sms_token?
    reset_sms_token.nil? || !reset_sms_period_valid?
  end

  def generate_reset_sms_token
    self.reset_sms_token = self.class.reset_sms_token
    self.reset_sms_sent_at = Time.now.utc
    self.reset_sms_token
  end

  def generate_reset_sms_token!
    generate_reset_sms_token && save(validate: false)
  end

  def clear_reset_sms_token
    self.reset_sms_token = nil
    self.reset_sms_sent_at = nil
  end

  module ClassMethods
    def send_reset_sms(attributes={})
      recoverable = find_or_initialize_with_errors([:phone], attributes, :not_found)
      recoverable.send_reset_sms if recoverable.persisted?
      recoverable
    end

    def reset_sms_token
      token_length = Youxin.config.devise.reset_sms_token_length - 1
      loop do
        token = rand(9*10**token_length) + 10**token_length
        break token unless where(reset_sms_token: token).exists?
      end
    end

    def reset_password_by_sms(attributes={})
      recoverable = find_or_initialize_with_error_by(:reset_sms_token, attributes[:reset_sms_token])
      if recoverable.persisted?
        if recoverable.reset_sms_period_valid?
          recoverable.reset_password_by_sms!(attributes[:password], attributes[:password_confirmation])
        else
          recoverable.errors.add(:reset_sms_token, :expired)
        end
      end
      recoverable
    end
  end
end
