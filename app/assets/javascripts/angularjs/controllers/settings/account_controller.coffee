@AccountController = ['$scope', 'Account',($scope, Account)->
  $scope.navs = [
    {
      name: 'profile'
      title: '基本信息'
      url: '/settings/account/profile'
    },
    {
      name: 'password'
      title: '修改密码'
      url: '/settings/account/password'
    }
  ]
  Account.get (data) ->
    if data.user.namespace.detailable
      $scope.navs.push
        name: 'details'
        title: '详细信息'
        url: '/settings/account/details'

  $scope.prepare_breadcrumbs(1)
  $scope.breadcrumbs.push(
    {
      name: '个人设置',
      url: '/settings/account/profile'
    }
  )
]

@ChangePasswordController = ["$scope", "$http",($scope, $http)->
  $scope.setActive($scope.navs, 'password')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '修改密码'
    url: '/settings/account/password'

  $scope.submit = ()->
    data =
      user:
        current_password: $scope.currentPassword
        password: $scope.password
        password_confirmation: $scope.passwordConfirmation
    $http.put("/account.json", data).success (data)->
      App.alert("修改成功")
    .error (data,status)->
      App.alert("修改失败,请重试", 'error')
]

@ChangeProfileController = ["$scope", "$http",($scope, $http)->
  $scope.setActive($scope.navs, 'profile')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '基本信息'
    url: '/settings/account/password'

  # getUserInformations = (callback, callbackerror)->
  #   $http.get("/account.json").success (data, _status)->
  #     callback(data.user, _status)
  #   .error (_data, _status)->
  #     callbackerror(_data, _status)

  # getUserInformations((data)->
  #   $scope.user = data
  # )

  $http.get("/account.json").success (data, _status)->
    $scope.user = data.user
  .error (_data, _status)->
    console.log _data

  $scope.submit = ()->
    data = {}
    data.user = $scope.user
    $http.put("/account.json", data).success ()->
      App.alert("保存成功")
    .error (_data,_status)->
      App.alert("提交失败", 'error')

  $scope.uploadAvatar = (ele) ->
    $(ele).next().text("正在上传...")
    form = $(ele).parents('form')
    form.ajaxSubmit
      type: 'PUT'
      error: (event, statusText, responseText, form) ->
        App.alert("修改头像失败, 请重新操作", 'error')
        $(ele).next().text("修改头像")
      success: (responseText, statusText, xhr, form) ->
        $scope.$apply ->
          $scope.user = responseText.user
        $(ele).next().text("修改头像")

]

@ChangeDetailsController = ['$scope', 'DetailOptions', 'Account', ($scope, DetailOptions, Account)->
  $scope.setActive($scope.navs, 'details')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '详细信息'
    url: '/settings/account/details'

  DetailOptions.get {}, (options) ->
    $scope.political_status_options = options.political_status_options
    $scope.type_of_household_options = options.type_of_household_options

  datePicker = $('.birthday-input').datepicker
    format: 'yyyy-mm-dd'
    language: 'zh-CN'
    todayBtn: true
    orientation: 'top right'
    endDate: 'getDate()'
    startView: 'decade'

  Account.get (data) ->
    $scope.account = data.user

  $scope.update = (account) ->
    account.birthday = datePicker.val()
    Account.update { user: account }, (data) ->
      App.alert('保存成功')
    , (response) ->
      App.alert('提交失败', 'error')


]
