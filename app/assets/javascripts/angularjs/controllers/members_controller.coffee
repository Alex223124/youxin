@MembersController = ['$scope', '$http', '$route', '$routeParams', ($scope, $http, $route, $routeParams) ->
  organization_id = $routeParams['id']
  $scope.members = []
  $http.get("/organizations/#{organization_id}/members.json")
  .success (data) ->
    $scope.members = data.members
  .error (data) ->
    fixed_alert("数据加载失败")
    # $scope.members = [
    #   {
    #     id: "78756"
    #     name: "laoguanjie"
    #     phone: "13673416911"
    #     position: "student"
    #     userPic: "image/user-pic.png"
    #   }
    #   {
    #     id: "78734"
    #     name: "zhulin"
    #     phone: "13673416911"
    #     position: "student"
    #     userPic: "image/user-pic.png"
    #   }
    #   {
    #     id: "7876"
    #     name: "haolo"
    #     phone: "13673416911"
    #     position: "student"
    #     userPic: "image/user-pic.png"
    #   }
    # ]

  $http.get('/organizations.json').success (data)->
    for organization in data.organizations
      new Organization(organization)
    Organization.setIndex(false)
    $scope.organizations = Organization.all
    for _i in $scope.organizations
      _i.expandFlag = true
    $scope.activeElement = $scope.organizations.first()
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

  $scope.position_options = [
    "学生"
    "老师"
    "教授"
    "院长"
    "辅导员"
  ]
  

  $scope.options = 
    expand: true
    insert: false
    remove: false
    select: false

  $scope.activeFn = (org)->
    $("#org-tree-container").children(".active").removeClass("active")
    $("#org-tree-container").children().eq(org.index).addClass("active")
    $http.get("/organizations/#{org.id}/authorized_users").success (data) ->
      $scope.activeElementMembers = data.members
    .error (data)->
      fixed_alert("获取组织成员失败,请重新操作！")



  ###$scope.importOrgList = [
    {
      id: 4657
      name: "liuxinntasuha"
      phone: 13946575645
      position: "student"
      userPic: "image/user-pic.png"
    }
    {
      id: 4563
      name: "liuxin"
      phone: 13965575745
      position: "student"
      userPic: "image/user-pic.png"
    }
    {
      id: 676546
      name: "liuxin"
      phone: 13946575984
      position: "student"
      userPic: "image/user-pic.png"
    }
  ]###

  $scope.removeMember = (_id)->
    thisIndex = $scope.members.indexOfProperty("id",parseInt(_id))
    $scope.members.splice(thisIndex,1)
    if $scope.members.length is 0
      $scope.hasOrgMember = false

  $scope.hasOrgMember = true

  $scope.removeAll = ()->
    $scope.members = []
    $scope.hasOrgMember = false

  $scope.addNewOrgMember = ($http)->
    objCache = 
      name: $scope.user_name
      phone: $scope.user_tel
      position: "student"
      userPic: "image/user-pic.png"
      studentNumber: $scope.user_studentNumber
    $http.post("url",objCache).success (data)->
      $scope.members.push(data)
    $scope.user_name = ""
    $scope.user_tel = ""
    $scope.user_studentNumber = ""
    $scope.hasOrgMember = true

  $scope.addToCurrentOrg = (_id)->
    if $scope.members.isInArrayOfProperty("id",_id)
      _obj = $scope.activeElementMembers.objOfProperty("id",_id)
      fixed_alert("#{_obj.name} 已经在组织中了！")
    else
      $scope.members.push($scope.activeElementMembers.objOfProperty("id",_id))
      $scope.hasOrgMember = true

]