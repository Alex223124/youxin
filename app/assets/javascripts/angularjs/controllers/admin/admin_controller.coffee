@AdminController = ["$scope", ($scope)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
    {
      name: '组织管理'
      url: '/user/organizations'
    }
  ]
]