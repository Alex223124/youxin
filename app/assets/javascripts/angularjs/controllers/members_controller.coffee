@MembersController = ['$scope', '$http', '$route', '$routeParams', ($scope, $http, $route, $routeParams) ->
  organization_id = $routeParams['id']
  $scope.members = []
  $http.get("/organizations/#{organization_id}/members.json")
  .success (data) ->
    $scope.members = data.members
  .error (data) ->
    fixed_alert("数据加载失败")

  $http.get('/organizations.json').success (data)->
    for organization in data.organizations
      new Organization(organization)
    Organization.setIndex(false)
    $scope.organizations = Organization.all
    for _i in $scope.organizations
      _i.expandFlag = true
    $scope.activeElement = $scope.organizations.first()
    $scope.current_organization = $scope.organizations.objOfProperty("id", organization_id)
    $http.get("/organizations/#{$scope.activeElement.id}/members.json").success (data)->
      $scope.activeElementMembers = data.members
    .error (_data, _status)->
      switch _status
        when 403
          fixed_alert("您没有该组织的管理权限！")
        else
          fixed_alert("获取组织成员失败,请重新操作！")
  .error (_data, _status)->
    switch _status
      when 403
        fixed_alert("您没有该组织的管理权限！")
      else
        fixed_alert("获取组织失败,请重新操作！")   

  $http.get("/help/positions").success (data)->
    $scope.position_options = data.positions
  .error (_data,_status)->
    $scope.position_options = []

  $scope.callback = (newOption, member, oldOption)->
    if oldOption is null or (newOption.id isnt oldOption.id)
      data = getData(member.id, newOption.id)
      $http.put("/organizations/#{organization_id}/members", data).success ()->
        return true
      .error ()->
        fixed_alert("由于网络原因，您需要重新操作！")
        return false
    else
      return true

  $scope.org_tree_options = 
    expand: true
    insert: false
    remove: false
    select: false

  $scope.activeFn = (org)->
    $("#org-tree-container").children(".active").removeClass("active")
    $("#org-tree-container").children().eq(org.index).addClass("active")
    $http.get("/organizations/#{org.id}/members.json").success (data) ->
      $scope.activeElementMembers = data.members
    .error (data)->
      fixed_alert("获取组织成员失败,请重新操作！")

  getData = (_id1,_id2)->
    _result = {}
    _result.member_ids = []
    _result.member_ids.push(_id1)
    if _id2 isnt undefined
      _result.position_id = _id2
    _result

  $scope.removeMember = (_id)->
    data = getData(_id)
    data.method = 'delete'
    $http.put("/organizations/#{organization_id}/members", data).success ()->
      thisIndex = $scope.members.indexOfProperty("id",_id)
      $scope.members.splice(thisIndex,1)
      if $scope.members.length is 0
        $scope.hasOrgMember = false
    .error ()->
      fixed_alert("删除失败!")  

  $scope.hasOrgMember = true

  $scope.updatePhone = (member)->
    data = {}
    data.user = 
      phone: member.phone
    $http.put("/users/#{member.id}", data).success ()->
      fixed_alert("修改成功!")
    .error (_data)->
      fixed_alert("修改失败!")

  $scope.removeAll = ()->
    $scope.members = []
    $scope.hasOrgMember = false

  $scope.addNewOrgMember = ()->
    objCache =
      user:
        name: $scope.user_name
        phone: $scope.user_tel
    $http.post("/organizations/#{organization_id}/members", objCache).success (data)->
      $scope.members.push(data.member)
    $scope.user_name = ""
    $scope.user_tel = ""
    $scope.hasOrgMember = true

  $scope.addToCurrentOrg = (_id)->
    if $scope.members.isInArrayOfProperty("id",_id)
      _obj = $scope.activeElementMembers.objOfProperty("id",_id)
      fixed_alert("#{_obj.name} 已经在组织中了！")
    else
      data = getData(_id)
      data.method = "put"
      $http.put("/organizations/#{organization_id}/members", data).success ()->
        $scope.members.push($scope.activeElementMembers.objOfProperty("id",_id))
        $scope.hasOrgMember = true
      .error ()->
        fixed_alert("#{$scope.members.last().name} 添加失败!")
]


###data =
  user:
    phone: 'phone'
"/users/#{id}", data###