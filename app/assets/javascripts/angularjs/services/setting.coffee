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
