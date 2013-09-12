@app.factory "systemSettingService", ["$http", ($http)->
  serviceCache = {}
  #private
  initial = (method, url, data, success, error)->
    $http[method](url, data).success (data, status)->
      if success
        success(data, status)
    .error (data, status)->
      if error
        error(data, status)

  serviceCache.getPushSetting = (success, error)->
    initial("get", "url", false, success, error)

  serviceCache.updatePushSetting = (update_data, success, error)->
    initial("update", "url", update_data, success, error)


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

  serviceCache.getSystemSettings = (success, error)->
    initial("get", "/namespace.json", false, success, error)

  serviceCache.setSystemSettings = (update_data, success, error)->
    initial("update", "/namespace.json", { namespace: update_data }, success, error)

  serviceCache.getSystemLogo = (success, error)->
    initial("get", "url", false, success, error)

  serviceCache.setSystemLogo = (update_data, success, error)->
    initial("update", "url", update_data, success, error)

  serviceCache.getPositions = (success, error)->
    initial("get", "url", false, success, error)

  serviceCache.updatePositions = (update_data, success, error)->
    initial("update","url", update_data, success, error)

  return serviceCache
]
