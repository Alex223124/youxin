@ReceiptsController = ['$scope', 'receiptService', '$http', ($scope, receiptService, $http) ->
  $scope.breadcrumbs = [
    {
      name: '首页'
      href: '/'
    }
  ]

  $scope.max_receipt_id = new Array(24).join('0')
  $scope.min_receipt_id = new Array(24).join('f')


  receiptService.getReceipts {params: {status: "read" }}, (data)->
    for receipt in data.receipts
      receipt.comments_open_status = false
    $scope.read_receipts = data.receipts
    set_receipt_range_for_array(data.receipts)


  receiptService.getReceipts {params: {status: "unread"}}, (data)->
    for receipt in data.receipts
      receipt.comments_open_status = false
    $scope.unread_receipts = data.receipts
    set_receipt_range_for_array(data.receipts)

  set_receipt_range = (receipt) ->
    return unless receipt
    $scope.max_receipt_id = receipt.id if receipt.id > $scope.max_receipt_id
    $scope.min_receipt_id = receipt.id if receipt.id < $scope.min_receipt_id

  set_receipt_range_for_array = (array) ->
    set_receipt_range(array.first())
    set_receipt_range(array.last())

  move_reads = () ->
    compensatory_index = 0
    for receipt, index in $scope.unread_receipts
      current_index = index - compensatory_index
      if $scope.unread_receipts[current_index].read
        $scope.read_receipts = $scope.read_receipts.concat $scope.unread_receipts.splice(current_index, 1)
        compensatory_index += 1

  $scope.refresh = () ->
    params =
      params:
        status: "unread"
        since_id: $scope.max_receipt_id
    receiptService.getReceipts params, (data)->
      if data.receipts.length
        $scope.unread_receipts = $scope.unread_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
      else
        App.alert('暂时没有未读消息', 'info')
    , (data, status)->
      App.alert "加载失败", "error"
    Youxin.updateNotificationsCounter()
    move_reads()

  $scope.load_more = (event) ->
    params = 
      params:
        status: "read"
        max_id: $scope.min_receipt_id

    receiptService.getReceipts params, (data)->
      if data.receipts.length
        $scope.read_receipts = $scope.read_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
        App.alert("加载了 #{data.receipts.length} 条消息")
      else
        angular.element(event.target).attr('disabled', true).html('没有更多了')
        App.alert('没有更多了')
    , (data, status)->
      App.alert "加载失败", "error"



  $scope.fetch_attachments = (receipt) ->
    $scope.read_receipt(receipt)
    post = receipt.post
    unless post.attachments
      receipt.attachments_loading = true
      receiptService.getAttachments post.id, (data)->
        receipt.attachments_loading = false
        post.attachments = data.attachments

  $scope.fetch_unread_receipts = (receipt) ->
    post = receipt.post
    receiptService.getUnreadNameList post.id, (data)->
      post.unread_receipts = data.unread_receipts
      if post.unread_receipts.length > 12
        post.showing_unread_receipts = post.unread_receipts.slice(0,12)
      else
        post.showing_unread_receipts = data.unread_receipts
    receiptService.getSmsScheduler post.id, (data)->
      post.sms_scheduler = data.sms_scheduler
    $http.get("/posts/#{post.id}/last_call_scheduler.json").success (data) ->
      post.call_scheduler = data.call_scheduler

  $scope.fetch_comments = (receipt,$event) ->
    $scope.read_receipt(receipt)
    post = receipt.post
    receipt.comments_open_status = not receipt.comments_open_status
    if receipt.comments_open_status    
      receiptService.getComments post.id, (data)->
        post.comments = data.comments
        if post.comments.length > 5
          post.showing_comments = data.comments.slice(0, 5)
        else
          post.showing_comments = data.comments

  $scope.createComments = (receipt, e) ->
    post = receipt.post
    comment =
      body: post.commentBody
    receiptService.createComment post.id, {comment: comment}, (data)->
      angular.element(e.target).prev().click()
      console.log(data.comment)
      post.comments.unshift data.comment
      console.log(post.comments.slice(0,1))
      if post.comments.length > 5
        post.showing_comments = post.comments.slice(0, 5)
      else
        post.showing_comments = post.comments
    , (data, status)->
      App.alert('评论失败', 'error')

  $scope.form = {}

  $scope.getValueInObj = (input,collection)->
    switch input.type
      when "Field::TextField","Field::NumberField","Field::TextArea"
        return collection.objOfProperty("key",input.identifier).value

      when "Field::RadioButton"
        option_id = collection.objOfProperty("key",input.identifier).value
        return '' unless option_id?
        input.options.objOfProperty("id", option_id).value

      when "Field::CheckBox"
        _result = []
        option_ids = collection.objOfProperty("key",input.identifier).value
        return '' unless option_ids?
        for _i in option_ids
          _result.push(input.options.objOfProperty("id", _i).value)
        return _result.join(",")

  $scope.set_form_collections = (receipt)->
    form = receipt.post.forms.first()
    if receipt.origin
      receiptService.getFormCollections form.id, (data)->
        form.collections = data.collections
    $scope.form = form
    $("#form_collections").show()

  $scope.send_sms_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      receiptService.runNotificationNow post.id, ()->
        App.alert("系统已发送短信提醒")
        self.html("系统已发送短信提醒")
        self.attr("disabled","disabled")
      , ()->
        App.alert("发送失败", 'error')
  $scope.send_call_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_call_notifications_now.json").success () ->
        App.alert("系统已发送电话提醒")
        self.html("系统已发送电话提醒")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')

  $scope.send_sms_notifications_to_unfilleds = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_sms_notifications_to_unfilleds_now.json").success () ->
        App.alert("系统已发送短信提醒")
        self.html("已发送短信提醒")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')
  $scope.send_call_notifications_to_unfilleds = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_call_notifications_to_unfilleds_now.json").success () ->
        App.alert("系统已发送电话提醒")
        self.html("已发送电话提醒")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')

  $scope.fetch_forms = (receipt) ->
    $scope.read_receipt(receipt)
    post = receipt.post
    if receipt.origin or not post.forms
      $http.get("/posts/#{post.id}/forms.json").success (data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        receiptService.getFormCollection form.id, (data)->
          form.collectioned = true
          collection = data.collection
          for entity in collection.entities
            $scope.update_form(form, entity.key, entity.value)

    read_form_collapse_ele = $("\##{receipt.id}-read_receipts-forms")
    unread_form_collapse_ele = $("\##{receipt.id}-unread_receipts-forms")

    read_height = if read_form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    unread_height = if unread_form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    read_form_collapse_ele.css("height", read_height)
    unread_form_collapse_ele.css("height", unread_height)

  $scope.update_form = (form, key, value) ->
    for input in form.inputs
      if input.identifier is key
        key_input = input
        break
    return unless key_input
    switch key_input.type
      when "Field::TextField", "Field::TextArea", "Field::NumberField"
        key_input.default_value = value
      when "Field::RadioButton"
        for option in key_input.options
          if option.id is value
            key_input.default_value = option.value
            break
      when "Field::CheckBox"
        for option in key_input.options
          if value.getIndex(option.id) >= 0
            option.default_selected = true
          else
            option.default_selected = false

  $scope.favoriteable = (receipt) ->
    $scope.read_receipt(receipt)
    if receipt.favorited
      receiptService.cancelFavorite receipt.id, (data)->
        receipt.favorited = false
    else
      receiptService.favorite receipt.id, (data)->
        receipt.favorited = true

  $scope.expandable = (receipt) ->
    $scope.read_receipt(receipt)
    receipt.expanded = !receipt.expanded

  $scope.read_receipt = (receipt) ->
    if !receipt.read
      $http.put("/receipts/#{receipt.id}/read.json").success (data) ->
        receipt.read = true
        UnreadBubble.setBubble(UnreadBubble.getCurrentCount() - 1)

  $scope.mark_receipt_as_read = (receipt) ->
    $scope.read_receipt(receipt)

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')

  $scope.toggleAllUnread_receipts = (receipt,$event)->
    if receipt.post.showing_unread_receipts is receipt.post.unread_receipts
      receipt.post.showing_unread_receipts = receipt.post.unread_receipts.slice(0, 12)
      $($event.target).text("查看全部名单")
    else
      receipt.post.showing_unread_receipts = receipt.post.unread_receipts
      $($event.target).text("收起全部名单")

  $scope.toggleAllcomments = (receipt, $event)->
    if receipt.post.showing_comments is receipt.post.comments
      receipt.post.showing_comments = receipt.post.comments.slice(0, 5)
      $($event.target).text("查看更久以前的评论")
      $($event.target).siblings("input").focus()
    else
      receipt.post.showing_comments = receipt.post.comments
      $($event.target).text("收起更久以前的评论")

  $scope
]
