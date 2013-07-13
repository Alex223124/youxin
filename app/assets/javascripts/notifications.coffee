#= require faye/faye-browser
#= require notifier
window.Youxin =
  notifier: new window.Notifier()

  initNotificationSubscribe : () ->
    if CURRENT_USER_NOTIFICATION_CHANNEL isnt ''
      faye = new Faye.Client(FAYE_SERVER_URL)
      channel = "/#{SUBSCRIPTION_PREFIX}/#{CURRENT_USER_NOTIFICATION_CHANNEL}"
      faye.subscribe channel, (data) ->
        json = data.json
        url = Youxin.fixUrlDash("#{ROOT_URL}#{json.content_path}")
        avatar = Youxin.fixUrlDash("#{ROOT_URL}#{json.avatar}")
        Youxin.notifier.notify(avatar, json.title, json.content, url)

  fixUrlDash : (url) ->
    url.replace(/\/\//g,"/").replace(/:\//,"://")
