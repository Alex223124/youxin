@app.factory "receiptService", ["$http", ($http)->
  #private
  initial = (method, url, data, success, error)->
    $http[method](url, data).success (data, status)->
      if success
        success(data, status)
    .error (data, status)->
      if error
        error(data, status)

  #public
  serviceCache =
    #标记某条消息为已读
    readReceipt: (id, success, error)->
      initial("put", "/receipts/#{id}/read.json", false, success, error)

    #根据消息id获取完整的消息
    getFullPost: (id, success, error)->
      initial("get", "/receipts/#{id}.json", false, success, error)

    #获取优信(包括已读,未读和加载更多,通过data确定已读和未读)
    getReceipts: (data, success, error)->
      initial("get", "/receipts.json", data, success, error)

    #获取某条消息的附件
    getAttachments: (id, success, error)->
      initial("get", "/posts/#{id}/attachments.json", false, success, error)

    #获取某条消息的表格
    getForms: (id, success, error)->
      initial("get", "/posts/#{id}/forms.json", false, success, error)

    #获取某条消息的评论
    getComments: (id, success, error)->
      initial("get", "/posts/#{id}/comments.json", false, success, error)

    #获取某条消息的未读名单
    getUnreadNameList: (id, success, error)->
      initial("get", "/posts/#{id}/unread_receipts.json", false, success, error)

    #
    getSmsScheduler: (id, success, error)->
      initial("get", "/posts/#{id}/last_sms_scheduler.json", false, success, error)

    #
    getCallScheduler: (id, success, error)->
      initial("get", "/posts/#{id}/last_call_scheduler.json", false, success, error)

    #标记为收藏
    favorite: (id, success, error)->
      initial("post", "/receipts/#{id}/favorite.json", false, success, error)

    #取消收藏
    cancelFavorite: (id, success, error)->
      initial("delete", "/receipts/#{id}/favorite.json", false, success, error)

    #标记为已读
    putReadFlag: (id, success, error)->
      initial("put", "/receipts/#{id}/read.json", false, success, error)

    #短信通知未读
    runNotificationNow: (id, success, error)->
      initial("post", "/posts/#{id}/run_sms_notifications_now.json", false, success, error)

    #
    runCallNotificationNow: (id, success, error)->
      initial("post", "/posts/#{id}/run_call_notifications_now.json", false, success, error)

    #
    runSmsNotificatinosTo: (id, success, error)->
      initial("post", "/posts/#{id}/run_sms_notifications_to_unfilleds_now.josn", false, success, error)

    #
    runCallNotificationTo: (id, success, error)->
      initial("post", "/posts/#{id}/run_call_notifications_to_unfilleds_now.json", false, success, error)

    #提交表格
    submitForms: (id, data, success, error)->
      initial("post", "/forms/#{id}/collections.json", data, success, error)

    #发表评论
    createComment: (id, data, success, error)->
      initial("post", "/posts/#{id}/comments.json", data, success, error)

    #
    getFormCollections: (id, success, error)->
      initial("get", "/forms/#{id}/collections.json", false, success, error)

    getFormCollection: (id, success, error)->
      initial("get", "/forms/#{id}/collection.json", false, success, error)

  serviceCache
]
