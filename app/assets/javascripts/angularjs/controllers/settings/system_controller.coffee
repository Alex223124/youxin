@SystemController = ["$scope", "$http",($scope, $http)->
  $scope.navs = [
    {
      name: 'logo',
      title: '系统 LOGO',
      url: '/settings/system/logo'
    },
    {
      name: 'position',
      title: '身份设置',
      url: '/settings/system/position'
    },
    {
      name: 'push',
      title: '推送设置',
      url: '/settings/system/push'
    }
  ]

  $scope.prepare_breadcrumbs(1)
  $scope.breadcrumbs.push(
    {
      name: '系统设置',
      url: '/settings/system/logo'
    }
  )

]

@SystemLogoController = ["$scope", "systemSettingService",($scope, systemSettingService)->
  $scope.setActive($scope.navs, 'logo')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '修改系统 LOGO'
    url: '/settings/system/logo'

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

@SystemPositionController = ["$scope", "systemSettingService",($scope, systemSettingService)->
  $scope.setActive($scope.navs, 'position')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '身份设置'
    url: '/settings/system/position'

]

@SystemPushController = ["$scope", "$http", "systemSettingService", ($scope, $http, systemSettingService)->
  $scope.setActive($scope.navs, 'push')

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '推送设置'
    url: '/settings/system/push'

  $scope.pushSettings = systemSettingService.pushSettings

  $scope.safeApply = (fn)->
    phase = this.$root.$$phase
    if phase is '$apply' or phase is '$digest'
      if fn and (typeof fn is 'function')
        fn()
    else
      this.$apply(fn)

  $scope.delayUnitOptions = systemSettingService.delayUnitOptions

  $scope.callback = ()->
    return true

  $scope.check = (baseon)->
    $scope.pushSettings[baseon].delayTime = if !!$scope.pushSettings[baseon].delayTime then $scope.pushSettings[baseon].delayTime else 0
    $scope.safeApply $scope.pushSettings[baseon].delayTime

  $scope.changeDelay = (baseon, delta)->
    $scope.pushSettings[baseon].delayTime = parseInt($scope.pushSettings[baseon].delayTime) + parseInt(delta)
    $scope.pushSettings[baseon].delayTime = if $scope.pushSettings[baseon].delayTime < 0 then 0 else $scope.pushSettings[baseon].delayTime
    $scope.safeApply $scope.pushSettings[baseon].delayTime

  $scope.update = ()->
    console.log ($scope.pushSettings)
    # systemSettingService.updatePushSetting $scope.pushSettings, (data,status)->
    #   App.alert("保存成功")
    # , (data)->
    #   App.alert("保存失败")

]