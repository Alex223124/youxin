@OrganizationsController = ['$scope', '$http', ($scope, $http) ->
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

  getAllOrganizations((data)->
    $scope.orgs = data
    for _i in $scope.orgs
      _i.expandFlag = true
    $scope.defaultActiveEle = data[0]
    $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
    getOrganizationManagers($scope.defaultActiveEle.id, (managers)->
      $scope.defaultActiveEle.managers = managers
    )
  )

  $scope.$on "refresh", ()->
    getAllOrganizations (data)->
      $scope.orgs = data
      for _i in $scope.orgs
        _i.expandFlag = true
      $scope.defaultActiveEle = data[0]
      $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
      getOrganizationManagers($scope.defaultActiveEle.id, (managers)->
        $scope.defaultActiveEle.managers = managers
      )
    ,(data, status)->
      $scope.$emit "refreshFail"


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
    if org.id
      $scope.defaultActiveEle.managers = []
      $scope.defaultActiveEle = org
      $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
      $("#all-organizations").children(".active").removeClass("active")
      $("#all-organizations").children().eq(org.index).addClass("active")
      getOrganizationManagers $scope.defaultActiveEle.id, (managers)->
        $scope.defaultActiveEle.managers = managers

  $scope.put_info = (data)->
    dataCache = {}
    dataCache.organization = data
    $http.put("/organizations/#{$scope.defaultActiveEle.id}",dataCache).error (_data,_status)->
      switch _status
        when 403
          fixed_alert("您没有该组织的管理权限！")
        else
          fixed_alert("修改失败，请重新操作！")
]
