@BillingController = ["$scope", ($scope)->
  $scope.breadcrumbs = [
    {
      name: '提醒记录'
      url: '/billing/sms'
    }
    {
      name: '短信提醒'
      url: '/billing/sms'
    }
  ]
  $scope.navs = [
    {
      name: 'sms',
      title: '短信提醒',
      url: '/billing/sms'
    },
    {
      name: 'call',
      title: '电话提醒',
      url: '/billing/call'
    }
  ]
  $scope.setActive = (navs, name) ->
    if navs
      for nav in navs
        if nav.name is name
          nav.class = 'active'
        else
          nav.class = ''
  $scope.prepare_breadcrumbs = (n) ->
    $scope.breadcrumbs.splice(n)

  $scope.showSinglePost = (record)->
    viewEle = angular.element(document.getElementById("singleReceiptView"))
    container = angular.element(document.getElementById("single_receipt"))
    viewEle.show(300)
    container.scope().ctrl.getReceipt(record.origin_receipt_id, 'recipients')
]

#private
getDateString = (picker)->
  _result = {}
  start_picker = picker.find('input[name="start"]')
  end_picker = picker.find('input[name="end"]')
  _result.start_date = start_picker.val()
  _result.end_date = end_picker.val()
  _result

@BillingSmsController = ["$scope", "billService", '$filter', ($scope, billService, $filter)->
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'sms')
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '短信提醒'
    url: '/billing/sms'

  $scope.date_range =
    start_date: $filter('date_for_datepicker')(new Date().beginning_of_week())
    end_date: $filter('date_for_datepicker')(new Date())

  billService.getSmsBill '', (data)->
    $scope.sms_records = data.sms_communication_records
    # Update daterange
    $('.input-daterange').find('input').datepicker('update')

  billService.getBillSummary '', (data) ->
    $scope.bill_summary = data.bill_summary

  datePicker = $('.input-daterange').datepicker
    format: "yyyy-mm-dd"
    language: "zh-CN"
    todayBtn: true
    orientation: "top right"
    endDate: "getDate()"

  $scope.submit = (event)->
    dateRange = getDateString(datePicker)
    date_reg = ///^\d{4}-\d{2}-\d{2}$///
    if dateRange.start_date.match(date_reg) and dateRange.end_date.match(date_reg)
      angular.element(event.target).attr('disabled', true).html('加载中')
      billService.getSmsBill dateRange, (data)->
        $scope.sms_records = data.sms_communication_records
        angular.element(event.target).attr('disabled', false).html('确定')
    else
      App.alert('日期有误，请重新选择', 'info')

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')

]

@BillingCallController = ["$scope", "billService", '$filter', ($scope, billService, $filter)->
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'call')
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '电话提醒'
    url: '/billing/call'

  $scope.date_range =
    start_date: $filter('date_for_datepicker')(new Date().beginning_of_week())
    end_date: $filter('date_for_datepicker')(new Date())

  billService.getCallBill '', (data)->
    $scope.call_records = data.call_communication_records
    # Update daterange
    $('.input-daterange').find('input').datepicker('update')

  billService.getBillSummary '', (data) ->
    $scope.bill_summary = data.bill_summary

  datePicker = $('.input-daterange').datepicker
    format: "yyyy-mm-dd"
    language: "zh-CN"
    todayBtn: true
    orientation: "top right"
    endDate: "getDate()"

  $scope.submit = (event)->
    dateRange = getDateString(datePicker)
    date_reg = ///^\d{4}-\d{2}-\d{2}$///
    if dateRange.start_date.match(date_reg) and dateRange.end_date.match(date_reg)
      angular.element(event.target).attr('disabled', true).html('加载中')
      billService.getCallBill dateRange, (data)->
        $scope.call_records = data.call_communication_records
        angular.element(event.target).attr('disabled', false).html('确定')
    else
      App.alert('日期有误，请重新选择', 'info')

  $scope.showTooltip = (event) ->
    $(event.target).tooltip('show')
  $scope.hideTooltip = (event) ->
    $(event.target).tooltip('hide')

]
