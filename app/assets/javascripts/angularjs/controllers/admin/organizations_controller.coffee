@AdminOrganizationsController = ['$scope', '$http', '$route', '$stateParams', '$location', ($scope, $http, $route, $stateParams, $location) ->
  getOrganizationsByUser = (callback, callbackerror)->
    $http.get("/account/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败", 'error')

  getAllOrganizations = (callback, callbackerror)->
    Organization.all = []
    $http.get('/account/authorized_organizations.json?actions[]=create_organization&actions[]=delete_organization&actions[]=edit_organization').success (_data)->
      for organization in _data.authorized_organizations
        new Organization(organization)
      Organization.setIndex(false)
      callback(Organization.all)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取所有组织失败", 'error')

  getMemberByOrganization = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/members.json").success (_data)->
      callback(_data.members)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取组织成员失败", 'error')

  unless $scope.orgs
    getAllOrganizations((data)->
      $scope.orgs = data
      for _i in $scope.orgs
        _i.expandFlag = true
      if $location.path() is "/admin/organizations"
        $location.path("/admin/organizations/#{$scope.orgs[0].id}")
        $scope.activeEle = $scope.orgs[0]
      $scope.$broadcast("gotAllOrganizations")
    )

  $scope.userOptions =
    expand: true
    insert: true
    remove: true
    select: false

  $scope.setActiveEle = (org)->
    $scope.activeEle = org

  $scope.setActiveElement = (org)->
    if org and org.id
      $location.path("/admin/organizations/#{org.id}")
]


@AdminOrganizationsProfileController = ['$scope', '$http', '$route', '$stateParams', '$location', ($scope, $http, $route, $stateParams, $location) ->
  organization_id = $stateParams['id']
  getOrganizationManagers = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/authorized_users.json").success (data)->
      callback(data.authorized_users)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取管理员信息失败", 'error')

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

  getOrgInfo = (id)->
    if $scope.orgs
      $scope.defaultActiveEle = $scope.orgs.objOfProperty("id", id)
      $scope.defaultActiveEle.managers = []
      $scope.defaultActiveEle.name_was = $scope.defaultActiveEle.name
      $scope.defaultActiveEle.bio_was = $scope.defaultActiveEle.bio
      $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
      getOrganizationManagers $scope.defaultActiveEle.id, (managers)->
        $scope.defaultActiveEle.managers = managers
      $scope.setActiveEle($scope.defaultActiveEle)
  getOrgInfo(organization_id)
  $scope.$on "gotAllOrganizations", ()->
    getOrgInfo(organization_id)

  $scope.put_info = (data)->
    for _k, _v of data
      if _v
        dataCache = {}
        dataCache.organization = data
        if _v isnt $scope.defaultActiveEle["#{_k}_was"]
          $http.put("/organizations/#{$scope.defaultActiveEle.id}.json",dataCache).success ()->
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