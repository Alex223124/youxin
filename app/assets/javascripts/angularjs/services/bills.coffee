@app.factory "billsService", ["$http", ($http)->
  #private
  initial = (method, url, config, success, error)->
    $http[method](url, config).success (data, status)->
      if success
        success(data, status)
    .error (data, status)->
      if error
        error(data, status)


  #public
  serviceCache = 
    #获取某个时间段内的短信推送记录
    getSmsbillsByMonth: (dateData, success, error)->
      initial("get", "url", dateData, success, error)

    #获取某月的电话推送记录
    getPhonebillsByMonth: (month, success, error)->
      initial("get", "url#{month}", false, success, error)


  serviceCache
]