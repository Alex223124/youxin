@moreInfoController = ["$scope", "$http",($scope, $http)->
  getUserInformations = (callback, callbackerror)->
    $http.get("/user").success (data, _status)->
      callback(data.user, _status)
    .error (_data, _status)->
      callbackerror(_data, _status)

  getUserInformations((data)->
    $scope.user = data
  )

  $scope.submit = ()->
    $http.put("/user",$scope.informations).success ()->
      App.alert("成功提交表单")
    .error (_data,_status)->
      App.alert("提交表单失败，请重试", 'error')

]