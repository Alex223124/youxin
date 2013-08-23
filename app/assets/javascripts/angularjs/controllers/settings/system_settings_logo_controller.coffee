@SystemSettingsLogoController = ["$scope", "systemSettingService",($scope, systemSettingService)->
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

  systemSettingService.getSystemLogo (data, status)->
    $scope.systemLogo = data
  ,(data, status)->
    $scope.systemLogo = ""
    App.alert("获取系统图标失败")

  $scope.updateLogo = ()->
    update_data = ""
    systemSettingService.setSystemLogo update_data, (data, status)->
      $scope.systemLogo = data
    ,(data, status)->
      App.alert("修改系统图标失败")
]
