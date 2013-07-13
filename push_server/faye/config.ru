require 'faye'
require 'faye/redis'
Faye::WebSocket.load_adapter('thin')

youxin_config = YAML.load_file("../../config/youxin.yml")[ENV['RACK_ENV'] || 'development']
FAYE_TOKEN = youxin_config["faye"]['token']

youxin_faye = Faye::RackAdapter.new(
  mount: '/faye',
  timeout: 25,
  engine: {
    type: Faye::Redis,
    host: 'localhost',
    namespace: 'faye'
  })
class FayeAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message["data"]
        if message["data"]['token'] != FAYE_TOKEN
          message['error'] = "Faye authorize faild."
        else
          message.delete('token')
        end
      end
    end
    callback.call(message)
  end
end
youxin_faye.add_extension(FayeAuth.new)

run youxin_faye
