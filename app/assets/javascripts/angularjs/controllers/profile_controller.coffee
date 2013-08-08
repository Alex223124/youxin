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
    $http.get("/user").success (data, _status)->
      callback(data.user, _status)
    .error (_data, _status)->
      callbackerror(_data, _status)

  getCurrentUserOrganizations = (callback, callbackerror)->
    $http.get("/user/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      fixed_alert("获取我所在的组织失败!")

  getCreatedReceipts = (callback,callbackerror)->
    $http.get("/user/created_receipts.json").success (_data,_status)->
      callback(_data.created_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getFavoritedReceipts = (callback,callbackerror)->
    $http.get("/user/favorited_receipts.json").success (_data,_status)->
      callback(_data.favorited_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getUserInformations (_data)->
    $scope.user = _data
  ,(_data,_status)->
    fixed_alert("获取信息失败!")

  getCurrentUserOrganizations (_data)->
    $scope.organizations = _data

  ###getCreatedReceipts (_data)->
    $scope.created_receipts = _data
  ,(_data,_status)->
    fixed_alert("获取发布的消息失败！")###

  $scope.refreshFavoritedReceipts = ()->    
    getFavoritedReceipts (_data)->
      $scope.favorited_receipts = _data
    ,(_data,_status)->
      fixed_alert("获取收藏的消息失败！")

  $scope.refreshCreatedReceipts = ()->
    getCreatedReceipts (_data)->
      $scope.created_receipts = _data
    ,(_data,_status)->
      fixed_alert("获取发布的消息失败！")

  $scope.refreshCreatedReceipts()
  $scope.refreshFavoritedReceipts()


  # Below from ReceiptsController
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
    unless post.unread_receipts
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
      fixed_alert('评论失败')

  $scope.fetch_forms = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.forms
      $http.get("/posts/#{post.id}/forms").success((data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        $http.get("/forms/#{form.id}/collection").success((data) ->
          form.collectioned = true
          collection = data.collection
          for entity in collection
            $scope.update_form(form, entity.key, entity.value)
        )
      )
    height = if $("\##{receipt.id}-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-forms").css("height",height)
    _height = if $("\##{receipt.id}-forms-created").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-forms-created").css("height",_height)

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


  #$scope.user = $h
]