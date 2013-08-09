@changePasswordController = ["$scope", "$http",($scope, $http)->
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
  $scope.submit = ()->
    data =
      user:
        current_password: $scope.currentPassword
        password: $scope.password
        password_confirmation: $scope.passwordConfirmation
    $http.put("/user", data).success (data)->
      App.alert("修改成功")
    .error (data,status)->
      App.alert("修改失败,请重试", 'error')
]