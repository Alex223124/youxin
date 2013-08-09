@OrganizationsController = ['$scope', '$http', '$route', '$routeParams', '$location', ($scope, $http, $route, $routeParams, $location) ->
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
  organization_id = $routeParams['id']

  getOrganizationsByUser = (callback, callbackerror)->
    $http.get("/user/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败", 'error')

  getAllOrganizations = (callback, callbackerror)->
    Organization.all = []
    $http.get('/user/authorized_organizations.json?actions[]=create_organization&actions[]=delete_organization&actions[]=edit_organization').success (_data)->
      for organization in _data.authorized_organizations
        new Organization(organization)
      Organization.setIndex(false)
      callback(Organization.all)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取所有组织失败", 'error')

  getMemberByOrganization = (org_id, _callback, callbackerror)->
    $http.get("/organizations/#{org_id}/members.json").success (_data)->
      _callback(_data.members)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取组织成员失败", 'error')

  getOrganizationManagers = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/authorized_users").success (data)->
      callback(data.authorized_users)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取管理员信息失败", 'error')

  unless $scope.orgs
    getAllOrganizations((data)->
      $scope.orgs = data
      for _i in $scope.orgs
        _i.expandFlag = true
        if _i.id is organization_id
          actived_organization = _i
      actived_organization = actived_organization or data[0]

      if actived_organization
        $scope.defaultActiveEle = actived_organization
        $scope.setActiveElement actived_organization
        $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)

        getOrganizationManagers($scope.defaultActiveEle.id, (managers)->
          $scope.defaultActiveEle.managers = managers
        )
    )

  $scope.userOptions =
    expand: true
    insert: true
    remove: true
    select: false

  parents = (org)->
    _result = []
    if typeof org.getAncestors isnt "Function" 
      org = $scope.orgs.objOfProperty("id", org.id)
    ((org)->
      if org.parent
        _result.unshift(org.parent)
        arguments.callee(org.parent)
      else
        return false
    )(org)
    _result

  $scope.setActiveElement = (org)->
    if org and org.id
      $scope.defaultActiveEle.managers = []
      $scope.defaultActiveEle = org

      $scope.defaultActiveEle.name_was = org.name
      $scope.defaultActiveEle.bio_was = org.bio

      $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
      $location.path("/organizations/#{org.id}")
      $("#all-organizations").children(".active").removeClass("active")
      $("#all-organizations").children().eq(org.index).addClass("active")
      getOrganizationManagers $scope.defaultActiveEle.id, (managers)->
        $scope.defaultActiveEle.managers = managers

  $scope.put_info = (data)->
    for _k, _v of data
      if _v
        dataCache = {}
        dataCache.organization = data
        if _v isnt $scope.defaultActiveEle["#{_k}_was"]
          $http.put("/organizations/#{$scope.defaultActiveEle.id}",dataCache).success ()->
            $scope.defaultActiveEle["#{_k}_was"] = _v
            App.alert("修改成功")
          .error (_data,_status)->
            switch _status
              when 403
                App.alert("您没有该组织的管理权限", 'error')
              else
                App.alert("修改失败，请重新操作", 'error')

  $scope.uploadAvatar = (ele)->
    form = $(ele).parents('form')
    form.attr(action: "/organizations/#{$scope.defaultActiveEle.id}")
    form.addClass('active').find('span').html('上传中 ...')
    form.ajaxSubmit
      type: 'PUT'
      error: (event, statusText, responseText, form) ->
        App.alert("修改头像失败, 请重新操作!", 'error')
        form.removeClass('active').find('span').html('修改头像')
      success: (responseText, statusText, xhr, form) ->
        form.removeClass('active').find('span').html('修改头像')
        $scope.$apply ->
          $scope.defaultActiveEle.avatar = responseText.organization.avatar
]
