@ReceiptsController = ['$scope', '$http', ($scope, $http) ->
  $scope.breadcrumbs = [
    {
      name: '首页'
      href: '/'
    }
  ]
  $scope.max_receipt_id = '0'
  $scope.min_receipt_id = 'z'

  $http.get('/receipts/read').success (data) ->
    $scope.read_receipts = data.receipts
    set_receipt_range_for_array(data.receipts)

  $http.get('/receipts/unread').success (data) ->
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
    $http.get("/receipts/unread?since_id=#{$scope.max_receipt_id}").success (data) ->
      if data.receipts.length
        $scope.unread_receipts = $scope.unread_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
      else
        App.alert('暂时没有未读消息', 'info')
    move_reads()

  $scope.load_more = (event) ->
    $http.get("/receipts/read?max_id=#{$scope.min_receipt_id}").success (data) ->
      if data.receipts.length
        $scope.read_receipts = $scope.read_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
        App.alert("加载了 #{data.receipts.length} 条消息")
      else
        angular.element(event.target).attr('disabled', true).html('没有更多了')
        App.alert('没有更多了')      

  $scope.fetch_attachments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.attachments
      receipt.attachments_loading = true
      $http.get("/posts/#{post.id}/attachments").success((data) ->
        receipt.attachments_loading = false
        post.attachments = data.attachments
      )

  $scope.fetch_unread_receipts = (receipt) ->
    post = receipt.post
    $http.get("/posts/#{post.id}/unread_receipts").success((data) ->
      post.unread_receipts = data.unread_receipts
    )

  $scope.fetch_comments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.comments
      $http.get("/posts/#{post.id}/comments").success((data) ->
        post.comments = data.comments
      )

  $scope.createComments = (receipt, e) ->
    post = receipt.post
    comment =
      body: post.commentBody
    $http.post("/posts/#{post.id}/comments", { comment: comment })
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
        return option_id and input.options.objOfProperty("id", option_id).value
        
      when "Field::CheckBox"
        _result = []
        option_ids = collection.objOfProperty("key",input.identifier).value
        for _i in option_ids
          _result.push(input.options.objOfProperty("id", _i).value)
        return _result.join(",")
        

  $scope.set_form_collections = (receipt)->
    $scope.form = receipt.post.forms.first()
    $("#form_collections").show()

  $scope.send_sms_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/sms_notifications").success () ->
        App.alert("系统已经发送短信通知")
        self.html("系统已经发送短信通知")
        self.attr("disabled","disabled")
      .error () ->
        App.alert("发送失败", 'error')

  $scope.fetch_forms = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.forms
      $http.get("/posts/#{post.id}/forms").success (data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        if receipt.origin
          $http.get("/forms/#{form.id}/collections").success (data) ->
            form.collections = data.collections
        $http.get("/forms/#{form.id}/collection").success (data) ->
          form.collectioned = true
          collection = data.collection
          for entity in collection
            $scope.update_form(form, entity.key, entity.value)

    height = if $("\##{receipt.id}-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-forms").css("height",height)

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
      $http.delete("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = false
      )
    else
      $http.post("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = true
      )
  $scope.expandable = (receipt) ->
    read_receipt(receipt)
    receipt.expanded = !receipt.expanded

  read_receipt = (receipt) ->
    unless receipt.read
      receipt.read = true
      $http.put("/receipts/#{receipt.id}/read")

]