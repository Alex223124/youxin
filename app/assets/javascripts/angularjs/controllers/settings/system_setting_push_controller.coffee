@SystemSettingPushController = ["$scope", "$http", "systemSettingService", ($scope, $http, systemSettingService)->
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