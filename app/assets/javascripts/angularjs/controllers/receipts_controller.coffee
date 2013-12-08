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
        current_receipt = $scope.unread_receipts.splice(current_index, 1).first()
        current_receipt.expanded = false
        $scope.read_receipts.push current_receipt
        compensatory_index += 1
    true

  $scope.refresh = () ->
    move_reads()
    params =
      params:
        status: "unread"
        since_id: $scope.max_receipt_id
    receiptService.getReceipts params, (data)->
      if data.receipts.length
        $scope.unread_receipts = $scope.unread_receipts.concat data.receipts
        set_receipt_range_for_array(data.receipts)
      else
    , (data, status)->
      App.alert "加载失败", "error"
    Youxin.updateNotificationsCounter()

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

  $scope.init_form_height = (receipt)->
    read_form_collapse_ele = $("\##{receipt.id}-read_receipts-forms")
    unread_form_collapse_ele = $("\##{receipt.id}-unread_receipts-forms")
    read_height = if read_form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    unread_height = if unread_form_collapse_ele.css("height") is "auto" then "0px" else "auto"
    read_form_collapse_ele.css("height", read_height)
    unread_form_collapse_ele.css("height", unread_height)

  $scope.form = []

  $scope
]
