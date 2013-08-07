@refreshController = ["$scope",($scope)->
  $scope.refresh = ()->
    $scope.$broadcast("refresh")
  $scope.$on "refreshFail", ()->
    fixed_alert("刷新失败,请重新操作!")
]