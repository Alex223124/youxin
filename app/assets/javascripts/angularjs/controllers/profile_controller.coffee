@profileController = ["$scope", "$http", ($scope, $http)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
    {
      name: '个人主页'
      url: '/user/organizations'
    }
  ]
  getUserInformations = (callback, callbackerror)->
    $http.get("/account.json").success (data, _status)->
      callback(data.user, _status)
    .error (_data, _status)->
      callbackerror(_data, _status)

  getCurrentUserOrganizations = (callback, callbackerror)->
    $http.get("/account/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败!", 'error')

  getCreatedReceipts = (callback,callbackerror)->
    $http.get("/account/created_receipts.json").success (_data,_status)->
      callback(_data.created_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getFavoritedReceipts = (callback,callbackerror)->
    $http.get("/account/favorited_receipts.json").success (_data,_status)->
      callback(_data.favorited_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getUserInformations (_data)->
    $scope.user = _data
  ,(_data,_status)->
    App.alert("获取信息失败!", 'error')

  getCurrentUserOrganizations (_data)->
    $scope.organizations = _data

  $scope.refreshFavoritedReceipts = ()->
    getFavoritedReceipts (_data)->
      $scope.favorited_receipts = _data
    ,(_data,_status)->
      App.alert("获取收藏的消息失败！", 'error')

  $scope.refreshCreatedReceipts = ()->
    getCreatedReceipts (_data)->
      $scope.created_receipts = _data
    ,(_data,_status)->
      App.alert("获取发布的消息失败！", 'error')

  $scope.refreshCreatedReceipts()
  $scope.refreshFavoritedReceipts()


  # Below from ReceiptsController
  $scope.fetch_attachments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.attachments
      receipt.attachments_loading = true
      $http.get("/posts/#{post.id}/attachments.json").success((data) ->
        receipt.attachments_loading = false
        post.attachments = data.attachments
      )

  $scope.fetch_unread_receipts = (receipt) ->
    post = receipt.post
    $http.get("/posts/#{post.id}/unread_receipts.json").success (data) ->
      post.unread_receipts = data.unread_receipts
    $http.get("/posts/#{post.id}/last_sms_scheduler.json").success (data) ->
      post.sms_scheduler = data.sms_scheduler
    $http.get("/posts/#{post.id}/last_call_scheduler.json").success (data) ->
      post.call_scheduler = data.call_scheduler

  $scope.fetch_comments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.comments
      $http.get("/posts/#{post.id}/comments.json").success((data) ->
        post.comments = data.comments
      )

  $scope.createComments = (receipt, e) ->
    post = receipt.post
    comment =
      body: post.commentBody
    $http.post("/posts/#{post.id}/comments.json", { comment: comment })
    .success (data) ->
      angular.element(e.target).prev().click()
      post.comments.unshift data.comment
    .error (data) ->
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
      $http.get("/forms/#{form.id}/collections.json").success (data) ->
        form.collections = data.collections

    $scope.form = form
    $("#form_collections").show()

  $scope.fetch_forms = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    if receipt.expanded or receipt.origin or not post.forms
      $http.get("/posts/#{post.id}/forms.json").success((data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        $http.get("/forms/#{form.id}/collection.json").success((data) ->
          form.collectioned = true
          collection = data.collection
          for entity in collection.entities
            $scope.update_form(form, entity.key, entity.value)
        )
      )
    height = if $("\##{receipt.id}-created_receipts-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-created_receipts-forms").css("height",height)
    _height = if $("\##{receipt.id}-favorited_receipts-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-favorited_receipts-forms").css("height",_height)

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
    read_receipt(receipt)
    if receipt.favorited
      $http.delete("/receipts/#{receipt.id}/favorite.json").success((data) ->
        receipt.favorited = false
      )
    else
      $http.post("/receipts/#{receipt.id}/favorite.json").success((data) ->
        receipt.favorited = true
      )
  $scope.expandable = (receipt) ->
    read_receipt(receipt)
    receipt.expanded = !receipt.expanded

  read_receipt = (receipt) ->
    if !receipt.read and receipt.forms_filled
      receipt.read = true
      $http.put("/receipts/#{receipt.id}/read.json")

  $scope.send_sms_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_sms_notifications_now.json").success () ->
        App.alert("系统已经发送短信通知")
        self.html("系统已经发送短信通知")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')
  $scope.send_call_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_call_notifications_now.json").success () ->
        App.alert("系统已经发送电话通知")
        self.html("系统已经发送电话通知")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')

  $scope.send_sms_notifications_to_unfilleds = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_sms_notifications_to_unfilleds_now.json").success () ->
        App.alert("系统已经发送短信通知")
        self.html("已发送短信通知")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')
  $scope.send_call_notifications_to_unfilleds = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/run_call_notifications_to_unfilleds_now.json").success () ->
        App.alert("系统已经发送电话通知")
        self.html("已发送电话通知")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')


  $scope
]