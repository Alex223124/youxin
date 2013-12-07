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

  $scope.init_form_height = (receipt)->
    form_collapse_ele = $("\##{receipt.id}-receipt-forms")
    height = if form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    form_collapse_ele.css("height", height)

  $scope
]
