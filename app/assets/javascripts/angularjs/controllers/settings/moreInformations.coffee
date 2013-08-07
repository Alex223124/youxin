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
      fixed_alert ("form had been submit succesfully!")
    .error (_data,_status)->
      fixed_alert ("failed to submit forms!")

]