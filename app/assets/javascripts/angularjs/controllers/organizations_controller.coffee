@OrganizationsController = ['$scope', '$http', ($scope, $http) ->
  $("#org_list").on "click", ".tab a", ()->
    self = $(this)
    self.parent()
    self.parent().addClass("active").siblings().removeClass()
    $(self.attr("data-target")).addClass("active").siblings().removeClass("active")
   
  Organization.all = []
  $http.get('/organizations.json').success (data) ->
    for organization in data.organizations
      new Organization(organization)
    Organization.setIndex(false)
    $scope.orgs = Organization.all
    for _i in $scope.orgs
      _i.expandFlag = true
    $scope.defaultActiveEle = Organization.all[0]
    $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
    $http.get("/organizations/#{$scope.defaultActiveEle.id}/authorized_users").success (data) ->
      $scope.defaultActiveEle.managers = data.authorized_users
    .error (data)->
      fixed_alert("获取管理员信息失败")
  .error (data) ->
    fixed_alert("获取信息失败")

  $http.get('/user/organizations.json')
  .success (data) ->
    $scope.organizations_self_in = data.organizations
  .error (data)->
    fixed_alert('加载"我的组织"失败!')
  $scope.userOptions =
    expand: true
    insert: true
    remove: true
    select: false
  $scope.selectresult = []
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
    $scope.defaultActiveEle.managers = []
    $scope.defaultActiveEle = org
    $scope.defaultActiveEle.parents = parents($scope.defaultActiveEle)
    $("#all-organizations").children(".active").removeClass("active")
    $("#all-organizations").children().eq(org.index).addClass("active")
    $("#organizations-self-in").children(".active").removeClass("active")
    $("#organizations-self-in").children().eq(arguments[1]).addClass("active")
    $http.get("/organizations/#{org.id}/authorized_users").success (data) ->
      $scope.defaultActiveEle.managers = data.authorized_users
    .error (data)->
      fixed_alert("获取管理员信息失败")

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
