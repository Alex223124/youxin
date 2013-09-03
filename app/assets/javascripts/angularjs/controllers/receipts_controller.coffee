@ReceiptsController = ['$scope', '$http', ($scope, $http) ->
  $scope.breadcrumbs = [
    {
      name: '首页'
      href: '/'
    }
  ]



  $scope.max_receipt_id = new Array(24).join('0')
  $scope.min_receipt_id = new Array(24).join('f')

  $http.get('/receipts.json?status=read').success (data) ->
    $scope.read_receipts = data.receipts
    set_receipt_range_for_array(data.receipts)

  $http.get('/receipts.json?status=unread').success (data) ->
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
    $http.get("/receipts.json?status=unread&since_id=#{$scope.max_receipt_id}").success (data) ->
      if data.receipts.length
        $scope.unread_receipts = $scope.unread_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
      else
        App.alert('暂时没有未读消息', 'info')
    move_reads()

  $scope.load_more = (event) ->
    $http.get("/receipts.json?status=read&max_id=#{$scope.min_receipt_id}").success (data) ->
      if data.receipts.length
        $scope.read_receipts = $scope.read_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
        App.alert("加载了 #{data.receipts.length} 条消息")
      else
        angular.element(event.target).attr('disabled', true).html('没有更多了')
        App.alert('没有更多了')

  $scope.fetch_attachments = (receipt) ->
    $scope.read_receipt(receipt)
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
    $scope.read_receipt(receipt)
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

  $scope.fetch_forms = (receipt) ->
    $scope.read_receipt(receipt)
    post = receipt.post
    unless post.forms
      $http.get("/posts/#{post.id}/forms.json").success (data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        $http.get("/forms/#{form.id}/collection.json").success (data) ->
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
      $http.delete("/receipts/#{receipt.id}/favorite.json").success((data) ->
        receipt.favorited = false
      )
    else
      $http.post("/receipts/#{receipt.id}/favorite.json").success((data) ->
        receipt.favorited = true
      )
  $scope.expandable = (receipt) ->
    $scope.read_receipt(receipt)
    receipt.expanded = !receipt.expanded

  $scope.read_receipt = (receipt) ->
    unless receipt.read
      $http.put("/receipts/#{receipt.id}/read.json").success (data) ->
        receipt.read = true

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')

  $scope
]