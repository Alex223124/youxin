@baseInfoController = ["$scope", "$http",($scope, $http)->
  # getUserInformations = (callback, callbackerror)->
  #   $http.get("/user.json").success (data, _status)->
  #     callback(data.user, _status)
  #   .error (_data, _status)->
  #     callbackerror(_data, _status)

  # getUserInformations((data)->
  #   $scope.user = data
  # )
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    },
    {
      name: '个人设置',
      url: '/user/organizations'
    }
  ]
  
  $http.get("/user.json").success (data, _status)->
    $scope.user = data.user
  .error (_data, _status)->
    console.log _data

  $scope.submit = ()->
    data = {}
    data.user = $scope.user
    $http.put("/user.json", data).success ()->
      App.alert("保存成功")
    .error (_data,_status)->
      App.alert("提交失败", 'error')

  $scope.uploadAvatar = (ele) ->
    form = $(ele).parents('form')
    form.ajaxSubmit
      type: 'PUT'
      error: (event, statusText, responseText, form) ->
        App.alert("修改头像失败, 请重新操作", 'error')
      success: (responseText, statusText, xhr, form) ->
        $scope.$apply ->
          $scope.user = responseText.user

]
