@NotificationsController = ["$scope", ($scope)->
  $scope.breadcrumbs = [
    {
      name: '通知'
      url: '/notifications/comments'
    }
    {
      name: '评论'
      url: '/notifications/comments'
    }
  ]
  $scope.navs = [
    {
      name: 'comments',
      title: '评论',
      url: '/notifications/comments'
    },
    {
      name: 'system',
      title: '系统消息',
      url: '/notifications/system'
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
]

@NotificationsCommentsController = ["$scope", ($scope)->
  $scope.test = ""
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'comments')

  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '评论'
    url: '/notifications/comments'

  $scope.comment_notifications = [
    {
      type: 'Notification::Comment'
      # post
      notificationable:
        id: '5214ca1fc23bf77a3900001c'
        title: 'title'
        body: 'body'
      # comment
      comment:
        id: 'test'
        body: 'body'
        created_at: 'time'
        user:
          avatar: 'avatar_url'
          name: 'name'
          id: 'id'
          email: 'email'
    }
    {
      type: 'Notification::Comment'
      # post
      notificationable:
        id: '5214ca1fc23bf77a3900001c'
        title: 'title'
        body: 'body'
      # comment
      comment:
        id: "test"
        user: 
          avatar: "src"
          name: "李四"
          id: "788787878"
        created_at: "2013-08-28T15:9:56+0800"
        body: "如果不介意把屏幕空白区域都用起来的话，倒是可以考虑把附件、表格什么的放在内容旁边展示"
    }
  ]
  $scope.showSinglePost = (notification)->
    viewEle = angular.element(document.getElementById("singleReceiptView"))
    container = angular.element(document.getElementById("single_receipt"))
    viewEle.show(300)
    container.scope().ctrl.getReceipt("comments", notification.notificationable.id, notification.comment)
]



@NotificationsSystemProfileController = ["$scope", ($scope)->
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'system')
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '系统消息'
    url: '/notifications/system'

  $scope.accountStatus =
    created_at: 'time',
    human_status: '短信发送成功',
    receipt:
      body: 'body',
      user:
        name: 'name',
        phone: 'phone_number'

    call:
      records: 33,
      fee: 23.3
    sms:
      records: 33,
      fee: 23.1

    when: "time"
    status:
      sentCounter: 33
      consumption: 23

  $scope.pushStatus = 
    post:
      title: "发布的标题"
      author:
        name: "发布者"
      body: "content"
      id: "id"
      status: "success"
      created_at: "time"
      profile:
        counter: 33
      aim_user:
        name: "接收者"

]



@BillsController = ["$scope", ($scope)->
  $scope.breadcrumbs = [
    {
      name: '账单'
      url: '/bills/sms'
    }
    {
      name: '短信账单'
      url: '/bills/sms'
    }
  ]
  $scope.navs = [
    {
      name: 'sms',
      title: '短信账单',
      url: '/bills/sms'
    },
    {
      name: 'phone',
      title: '电话账单',
      url: '/bills/phone'
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

]

#private
getDateString = ()->
  _result = {}
  now = new Date()
  year = now.getFullYear()
  month = if now.getMonth() < 9 then "0#{now.getMonth() + 1}" else (now.getMonth() + 1)
  date = if now.getDate() < 10 then "0#{now.getDate()}" else date
  _result.endDateString = "#{year}-#{month}-#{date}"
  _result.startDateString = "#{year}-#{month}-01"
  _result


@BillsSmsController = ["$scope", "billsService", ($scope, billsService)->
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'sms')
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '短信账单'
    url: '/bills/sms'


  billsService.getSmsbillsByMonth "month", (data)->
    $scope.accountStatus = data.accountStatus
    $scope.pushStatus = data.pushStatus

  $scope.accountStatus =
    created_at: 'time'
    human_status: '短信发送成功'
    receipt:
      body: 'body'
      user:
        name: 'name'
        phone: 'phone_number'
    call:
      records: 33
      fee: 23.3
    sms:
      records: 33
      fee: 23.1

  startDatePicker = $('#startDatePicker').datepicker 
    format: "yyyy-mm-dd"
    language: "zh-CN"

  endDatePicker = $('#end-date-picker').datepicker
    format: "yyyy-mm-dd"
    language: "zh-CN"
  
  $scope.limitDate = getDateString()
  $scope.submit = ()->
    billsService.getSmsbillsByMonth $scope.limitDate, (data)->
      $scope.accountStatus = data.accountStatus
]

@BillsPhoneController = ["$scope", ($scope)->
  $scope.prepare_breadcrumbs(1)
  $scope.setActive($scope.navs, 'phone')
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '电话账单'
    url: '/bills/phone'
]