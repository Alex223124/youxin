@app.factory "conversationService", ["$http", ($http)->
  serviceCache = {}
  #get the history
  serviceCache.getConversations = ()->
    $http.get("url").success (data, status)->
      serviceCache.conversations = data
    .error (data, status)->
      unless serviceCache.conversations
        serviceCache.conversations = []
      console.log "failed to require conversations"

  serviceCache.getNewConversation = (ids, data)->
    _data = {}
    _data.ids = ids
    $http.post("", _data).success (data, status)->
      serviceCache.newConversation = data
    .error (data, status)->
      unless serviceCache.newConversation
        serviceCache.newConversation = {}
      console.log "failed to require the new conversation"
]

@app.factory "systemSettingService", ["$http", ($http)->
  serviceCache = {}
  serviceCache.getPushSetting = (callback, callbackError)->
    $http.get("url").success (data, status)->
      callback(data, status)
    .error (data, status)->
      callbackError(data, status)

  serviceCache.updatePushSetting = (update_data, callback, callbackError)->
    $http.update("url", update_data).success (data, status)->
      callback(data, status)
    .error (data, status)->
      callbackError(data, status)

  serviceCache.delayUnitOptions = [
    {
      value: "hour"
      name: "小时"
    }
    {
      value: "min"
      name: "分钟"
    }
  ]

  serviceCache.pushSettings =
    emailPush:
      delayTime: 1
      delayUnit: serviceCache.delayUnitOptions[0]
    smsPush:
      delayTime: 3
      delayUnit: serviceCache.delayUnitOptions[0]
    phonePush:
      delayTime: 5
      delayUnit: serviceCache.delayUnitOptions[0]
    pushmethods:
      webBrowser: true
      email: true
      sms: true
      phone: false

  serviceCache.getSystemLogo = (callback, callbackError)->
    $http.get("url").success (data, status)->
      callback(data, status)
    .error (data, status)->
      callbackError(data, status)

  serviceCache.setSystemLogo = (update_data, callback, callbackError)->
    $http.update("url", data).success (data, status)->
      callback(data, status)
    .error (data, status)->
      callbackError(data, status)

  return serviceCache
]