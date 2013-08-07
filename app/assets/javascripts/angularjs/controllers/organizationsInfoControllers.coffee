@OrganizationsShowController = ["$scope", "$http", "$routeParams",($scope, $http ,$routeParams)->

  user_id = $routeParams['id']

  getOrganizationsByUser = (userId, callback, callbackerror)->
    $http.get("/users/#{userId}/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      fixed_alert("获取我所在的组织失败!")

  getAllOrganizations = (callback, callbackerror)->
    Organization.all = []
    $http.get('/organizations.json').success (_data)->
      for organization in _data.organizations
        new Organization(organization)
      Organization.setIndex(false)
      Organization.setExpandFlag(true)
      callback(Organization.all)
    .error (_data, _status)->
      callbackerror(_data, _status)
      fixed_alert("获取所有组织失败")

  getMemberByOrganization = (org_id, _callback, callbackerror)->
    $http.get("/organizations/#{org_id}/members.json").success (_data)->
      _callback(_data.members)
    .error (_data, _status)->
      callbackerror(_data, _status)
      fixed_alert("ha")

  getOrganizationManagers = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/authorized_users").success (data)->
      callback(data.authorized_users)
    .error (_data, _status)->
      callbackerror(_data, _status)
      fixed_alert("获取管理员信息失败")

  getOrganizationsByUser(user_id, (data)->
    $scope.organizations_self_in = data
  )
  getAllOrganizations((organizations)->
    $scope.organizations = organizations
    $scope.activeOrganization = setActive(organizations.first().id)
  )
  parents = (org)->
    _result = []
    if typeof org.getAncestors isnt "Function" 
      org = $scope.organizations.objOfProperty("id", org.id)
    ((org)->
      if org.parent
        _result.unshift(org.parent)
        arguments.callee(org.parent)
      else
        return false
    )(org)
    _result

  setActive = (_id)->
    _result = $scope.organizations.objOfProperty("id", _id)
    _result.parents = []
    getMemberByOrganization(_id, (data)->
      _result.members = data
      _result.parents = parents(_result)
    )
    getOrganizationManagers(_id, (data)->
      _result.managers = data
    )
    _result

  $scope.options=
    select: false
    expand: true
    insert: false
    remove: false

  $scope.$on "refresh", ()->
    getOrganizationsByUser(user_id, (data)->
      $scope.organizations_self_in = data
    ,()->
      $scope.$emit("refreshFail")
    )
    getAllOrganizations((organizations)->
      $scope.organizations = organizations
      $scope.activeOrganization = setActive(organizations.first().id)    
    ,()->
      $scope.$emit("refreshFail")
    )

  $scope.setActiveOrganization = (organization)->
    $scope.activeOrganization = setActive(organization.id)
    $("#all_organizations div").eq(organization.index).addClass("active").siblings().removeClass()

  $scope.moreInfoShow = false
]