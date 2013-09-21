@YouxinProfileController = ["$scope", 'receiptService', "$rootScope",($scope, receiptService, $rootScope)->
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
    receiptService.getSmsScheduler post.id, (data)->
      post.sms_scheduler = data.sms_scheduler

  $scope.fetch_comments = (receipt) ->
    $scope.read_receipt(receipt)
    post = receipt.post
    unless post.comments
      receiptService.getComments post.id, (data)->
        post.comments = data.comments

  $scope.createComments = (receipt, e) ->
    post = receipt.post
    comment =
      body: post.commentBody
    receiptService.createComment post.id, {comment: comment}, (data)->
      angular.element(e.target).prev().click()
      post.comments.unshift data.comment
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
        App.alert("系统已经发送短信通知")
        self.html("系统已经发送短信通知")
        self.attr("disabled","disabled")
      , ()->
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

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')

  $scope
]
