@YouxinProfileController = ["$scope", 'receiptService', "$rootScope", "$http", ($scope, receiptService, $rootScope, $http)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
    {
      name: '组织管理'
      url: '/user/organizations'
    }
  ]

  $rootScope.$on "$stateChangeStart", ()->
    $scope.closeReceipt()

  getCollapseIN = (data, collapseIN)->
    if data.post.attachmentted
      _result = "attachments"
    else if data.post.formed
      _result = "forms"
    else
      _result = "comments"
    if collapseIN is 'recipients'
      $scope.fetch_unread_receipts(data)
    _result = if collapseIN then collapseIN else _result
    _result

  showDefaultAddition = ()->
    #receiptId = $("#single_receipt").attr("receiptId")
    unless $("\##{$scope.receiptId}-receipt-#{$scope.collapseIN}").length
      setTimeout(showDefaultAddition, 500)
    else
      $("\##{$scope.receiptId}-receipt-#{$scope.collapseIN}").removeClass().addClass("in collapse")
      return $("\##{$scope.receiptId}-receipt-#{$scope.collapseIN}")

  #this is test function, the data is static
  $scope.getReceipt = (id, collapseIN ,currentComment)->
    $scope.receiptId = id
    receiptService.getFullPost $scope.receiptId, (data) ->
      data = data.receipt
      $scope.receipt = []
      data.read = true
      if currentComment
        currentComment.id = "#{currentComment.id}-comment"
        data.post.comments.unshift(currentComment)
      $scope.collapseIN = getCollapseIN(data, collapseIN)
      data.expanded = true
      $scope.receipt.push(data)
      showDefaultAddition()

  $scope.closeReceipt = ()->
    $("#single_receipt").attr("receiptId", "")
    $("#singleReceiptView").fadeOut(300)
    $scope.receipt = []

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
      if data.unread_receipts.length > 12
        post.showing_unread_receipts = data.unread_receipts.slice(0,12)
      else
        post.showing_unread_receipts = data.unread_receipts
    receiptService.getSmsScheduler post.id, (data)->
      post.sms_scheduler = data.sms_scheduler

  $scope.fetch_comments = (receipt) ->
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
      post.comments.unshift data.comment
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
    unless post.forms
      receiptService.getForms post.id, (data)->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        receiptService.getFormCollection form.id, (data)->
          form.collectioned = true
          collection = data.collection
          for entity in collection.entities
            $scope.update_form(form, entity.key, entity.value)

    form_collapse_ele = $("\##{receipt.id}-receipt-forms")

    height = if form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    form_collapse_ele.css("height", height)

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
    unless receipt.read
      receipt.read = true
      receiptService.putReadFlag receipt.id
      UnreadBubble.setBubble(UnreadBubble.getCurrentCount() - 1)

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
