@changePasswordController = ["$scope", "$http",($scope, $http)->
  $scope.submit = ()->
    data =
      user:
        current_password: $scope.currentPassword
        password: $scope.password
        password_confirmation: $scope.passwordConfirmation
    $http.put("/user", data).success (data)->
      fixed_alert("修改成功!")
    .error (data,status)->
      fixed_alert("修改失败,请重试!")
]