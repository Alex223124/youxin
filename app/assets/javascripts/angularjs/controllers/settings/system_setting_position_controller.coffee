@SystemSettingsPositionController = ["$scope", "systemSettingService",($scope, systemSettingService)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    },
    {
      name: '系统设置',
      url: '/user/organizations'
    }
  ]


]