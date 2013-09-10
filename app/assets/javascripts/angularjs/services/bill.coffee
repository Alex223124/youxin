@app.factory "billService", ["$http", ($http)->
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
    getSmsBill: (dateData, success, error)->
      initial("get", "/billing/sms", { params: dateData }, success, error)

    #获取某月的电话推送记录
    getCallBill: (dateData, success, error)->
      initial("get", "/billing/call", { params: dateData }, success, error)

    getBillSummary: (month, success, error) ->
      initial("get", "/billing/bill_summary", { params: month }, success, error)

  serviceCache
]
