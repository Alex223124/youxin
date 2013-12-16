module Youxin
  module Util
    extend self

    def generate_random_string
      SecureRandom.base64(4).tr('+/', '-_')
    end
  end
end
