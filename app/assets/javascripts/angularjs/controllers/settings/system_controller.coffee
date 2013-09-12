@SystemController = ["$scope", "$http",($scope, $http)->
  $scope.navs = [
    {
      name: 'logo',
      title: '系统 LOGO',
      url: '/settings/system/logo'
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

  systemSettingService.getSystemSettings (data, status)->
    $scope.namespace = data.namespace
  ,(data, status)->
    $scope.namespace = {}
    App.alert("获取系统图标失败")

  $scope.uploadLogo = (ele)->
    form = $(ele).parents('form')
    form.attr(action: "/namespace.json")
    uploader_btn = form.find('.uploader-btn')
    uploader_btn.attr('disabled', true).html('上传中 ...')
    form.ajaxSubmit
      type: 'PUT'
      error: (event, statusText, responseText, form) ->
        uploader_btn.attr('disabled', false).html('选择图片')
        App.alert("修改 LOGO 失败, 请重新操作!", 'error')
      success: (responseText, statusText, xhr, form) ->
        $scope.$apply ->
          $scope.namespace.logo = responseText.namespace.logo
        uploader_btn.attr('disabled', false).html('选择图片')
]

@SystemPositionController = ["$scope", "systemSettingService",($scope, systemSettingService)->
  $scope.setActive($scope.navs, 'position')
  #private
  getwidth = (str)->
    cache =
      px3: ///[ijl]///g
      px4: ///[ftI]///g
      px7: ///[ckrsvxyzJ]///g
      px8: ///[abdeghnopquL0-9]///g
      px9: ///[ABEKPSTVXYZ]///g
      px10: ///[wUDCHNFGR]///g
      px11: ///[OQ]///g
      px12: ///[mM]///g
      px13: ///[W]///g
      px14: ///[\u4e00-\u9fa5]///g
    _result = 0
    for key,val of cache
      _a = str.match(val)
      if _a
        _result += _a.length * parseInt(key.match(///\d+///)[0])
    _result

  $scope.prepare_breadcrumbs(2)
  $scope.breadcrumbs = $scope.breadcrumbs.push
    name: '身份设置'
    url: '/settings/system/position'

  $scope.option = ""
  $scope.checkWidth = ($event)->
    if $event.keyCode is 13
      $scope.addNewPosition()
      $($event.target).width(10)
    else
      _width = getwidth($scope.option) + 10 
      $($event.target).width(_width)

  $scope.positions = [
    {
      name: "普通成员"
      id: "1"
    }
    {
      name: "管理员"
      id: "2"
    }
  ]
  $scope.addNewPosition = ()->
    unless $scope.option
      return false
    else
      cache =
        name: $scope.option
        id: undefined
      $scope.positions.push(cache)
      $scope.option = ""

  $scope.removePosition = (index)->
    $scope.positions.splice(index, 1)

  $scope.defaultPosition = $scope.positions[0]
  $scope.setDefaultPosition = (newOption, member, oldOption)->
    false
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

