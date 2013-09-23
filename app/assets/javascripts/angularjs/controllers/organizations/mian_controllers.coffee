@OrganizationsController = ["$scope", "$http", "$location", "$stateParams",($scope, $http, $location, $stateParams)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
    {
      name: '组织展示'
      url: '/user/organizations'
    }
  ]

  current_org_id = $stateParams["id"]
  getOrganizationsByUser = (callback, callbackerror)->
    $http.get("/account/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败", 'error')

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
      App.alert("获取所有组织失败", 'error')

  getMemberByOrganization = (org_id, _callback, callbackerror)->
    $http.get("/organizations/#{org_id}/members.json").success (_data)->
      _callback(_data.members)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取成员信息失败", 'error')

  getOrganizationManagers = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/authorized_users.json").success (data)->
      callback(data.authorized_users)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取管理员信息失败", 'error')


  getOrganizationsByUser (data)->
    $scope.organizations_self_in = data
    if $location.path() is "/organizations"
      $location.path("/organizations/#{data[0].id}")
      $scope.activeEle = data[0]

  getAllOrganizations (organizations)->
    $scope.organizations = organizations
    $scope.$broadcast("gotOrganizations")

  $scope.options=
    select: false
    expand: true
    insert: false
    remove: false

  $scope.setActiveOrganization = (organization)->
    $location.path("/organizations/#{organization.id}")


  $scope.setActiveEle = (org)->
    $scope.activeEle = org

  $scope.toggle = (selector)->
    current_height = $(selector).height()
    if current_height is 0
      $(selector).css "height", "auto"
    else
      $(selector).css "height", "0px"

  $scope.moreInfoShow = false

  $scope
]

@OrganizationsProfileController = ["$scope", "$http", "$location", "$stateParams",($scope, $http, $location, $stateParams)->
  current_org_id = $stateParams["id"]
  getOrganizationsByUser = (callback, callbackerror)->
    $http.get("/account/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败", 'error')

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
      App.alert("获取所有组织失败", 'error')

  getMemberByOrganization = (org_id, _callback, callbackerror)->
    $http.get("/organizations/#{org_id}/members.json").success (_data)->
      _callback(_data.members)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取成员信息失败", 'error')

  getOrganizationManagers = (org_id, callback, callbackerror)->
    $http.get("/organizations/#{org_id}/authorized_users.json").success (data)->
      callback(data.authorized_users)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取管理员信息失败", 'error')

  parents = (org, allOrganizations)->
    _result = []
    if typeof org.getAncestors isnt "Function" 
      org = allOrganizations.objOfProperty("id", org.id)
    ((org)->
      if org.parent
        _result.unshift(org.parent)
        arguments.callee(org.parent)
      else
        return false
    )(org)
    _result  

  getOrganizationInfo = (id)->
    if $scope.organizations
      $scope.activeOrganization = $scope.organizations.objOfProperty("id", id)
      getOrganizationManagers id, (data)->
        $scope.activeOrganization.managers = data
      getMemberByOrganization id, (data)->
        $scope.activeOrganization.parents = parents($scope.activeOrganization, $scope.organizations)
        $scope.activeOrganization.members = data
      $scope.setActiveEle($scope.activeOrganization)
  getOrganizationInfo(current_org_id)
  $scope.$on "gotOrganizations", ()->
    getOrganizationInfo(current_org_id)

]

@OrganizationMembersController = ['$scope', '$http', '$route', '$stateParams', '$filter', ($scope, $http, $route, $stateParams, $filter) ->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
  ]
  organization_id = $stateParams['id']
  $scope.members = []
  $scope.fail_memebers = []
  $http.get("/organizations/#{organization_id}/members.json")
  .success (data) ->
    $scope.members = data.members
  .error (data) ->
    App.alert("数据加载失败", 'error')

  $http.get('/organizations.json').success (data)->
    Organization.all = []
    for organization in data.organizations
      new Organization(organization)
    Organization.setIndex(false)
    $scope.organizations = Organization.all
    for _i in $scope.organizations
      _i.expandFlag = true
    $scope.activeElement = $scope.organizations.first()
    $scope.current_organization = $scope.organizations.objOfProperty("id", organization_id)
    $scope.breadcrumbs = $scope.breadcrumbs.concat [
      {
        name: $scope.current_organization.name
        url: "/admin/organizations/#{$scope.current_organization.id}"
      }
      {
        name: '成员管理'
        url: '/user/organizations'
      }
    ]
    $http.get("/organizations/#{$scope.activeElement.id}/members.json").success (data)->
      $scope.activeElementMembers = data.members
    .error (_data, _status)->
      switch _status
        when 403
          App.alert("您没有该组织的管理权限！", 'error')
        else
          App.alert("获取组织成员失败,请重新操作！", 'error')
  .error (_data, _status)->
    switch _status
      when 403
        App.alert("您没有该组织的管理权限！", 'error')
      else
        App.alert("获取组织失败,请重新操作！", 'error')   

  # $http.get("/help/positions.json").success (data)->
  #   $scope.position_options = data.positions
  # .error (_data,_status)->
  #   $scope.position_options = []
  $http.get("/help/roles.json").success (data)->
    data.roles.unshift({ id: '', name: '普通用户' })
    $scope.role_options = data.roles
  .error (_data,_status)->
    $scope.position_options = []

  $scope.callback = (newOption, member, oldOption)->
    if oldOption is null or (newOption.id isnt oldOption.id)
      if newOption.id is ''
        params = 
          'member_ids[]': [member.id]
        $http.delete("/organizations/#{organization_id}/members/role.json", { params: params }).success ()->
          return true
        .error ()->
          App.alert("由于网络原因，您需要重新操作！", 'error')
          return false
      else
        data = getData(member.id, newOption.id)
        $http.put("/organizations/#{organization_id}/members/role.json", data).success ()->
          return true
        .error ()->
          App.alert("由于网络原因，您需要重新操作！", 'error')
          return false
    else
      return true

  $scope.org_tree_options = 
    expand: true
    insert: false
    remove: false
    select: false

  $scope.activeFn = (org)->
    $("#org-list").find(".active").removeClass("active")
    $("#org-tree-container").children().eq(org.index).addClass("active")
    $http.get("/organizations/#{org.id}/members.json").success (data) ->
      $scope.activeElementMembers = data.members
    .error (data)->
      App.alert("获取组织成员失败,请重新操作！", 'error')

  $scope.getUsers = ($event)->
    $("#org-list").find(".active").removeClass("active")
    $($event.target).addClass("active")
    $http.get("/organizations/members.json").success (data)->
      $scope.activeElementMembers = data.members
    .error (data, status)->
      $scope.activeElementMembers = []
      App.alert("获取所有成员失败,请重新操作！", 'error')

  getData = (_id1,_id2)->
    _result = {}
    _result.member_ids = []
    _result.member_ids.push(_id1)
    if _id2 isnt undefined
      _result.role_id = _id2
    _result

  $scope.removeMember = (_id)->
    params = 
      'member_ids[]': [_id]
    $http.delete("/organizations/#{organization_id}/members.json", { params: params }).success ()->
      thisIndex = $scope.members.indexOfProperty("id",_id)
      $scope.members.splice(thisIndex,1)
      if $scope.members.length is 0
        $scope.hasOrgMember = false
    .error ()->
      App.alert("删除失败!", 'error')

  $scope.hasOrgMember = true

  $scope.updatePhone = (member)->
    data = {}
    data.user = 
      phone: member.phone
    $http.put("/users/#{member.id}.json", data).success ()->
      App.alert("修改成功!")
    .error (_data)->
      App.alert("修改失败!", 'error')

  $scope.removeAll = ()->
    ids = while $scope.members.last() 
      $scope.members.pop().id
    params =
      'member_ids[]': ids
    $http.delete("/organizations/#{organization_id}/members.json", { params: params }).success ()->
      App.alert("成功删除所有用户", 'success')
    .error ()->
      App.alert("删除失败", 'error')

    $scope.members = []
    $scope.hasOrgMember = false

  $scope.addNewOrgMember = ()->
    objCache =
      member:
        name: $scope.user_name
        email: $scope.user_email
        phone: $scope.user_tel
    $http.post("/organizations/#{organization_id}/members.json", objCache).success (data)->
      $scope.members.push(data.member)
      $scope.user_name = ""
      $scope.user_tel = ""
      $scope.user_email = ""
      App.alert("添加成功")
    .error ()->
      App.alert("添加失败，请检查输入是否合法", 'error')
    $scope.hasOrgMember = true

  $scope.addToCurrentOrg = (_id)->
    if $scope.members.isInArrayOfProperty("id",_id)
      _obj = $scope.activeElementMembers.objOfProperty("id",_id)
      App.alert("#{_obj.name} 已经在组织中了！", 'error')
    else
      data = getData(_id)
      $http.put("/organizations/#{organization_id}/members.json", data).success ()->
        $scope.members.push($scope.activeElementMembers.objOfProperty("id",_id))
        $scope.hasOrgMember = true
      .error ()->
        App.alert("#{$scope.members.last().name} 添加失败!", 'error')

  $scope.showFileName = (ele)->
    form = $(ele).parents("form")
    fileInfo = form.find("input").val()
    $scope.$apply ->
      $scope.fileName = fileInfo.split("\\").last()
  $scope.importUsers = (event) ->
    unless ///\.xls///.test $scope.fileName
      App.alert("文件类型错误，请选择 Excel(2003) 文件", 'error')
      return false
    $scope.fail_memebers = []
    submit_btn = $(event.target)
    form = submit_btn.siblings("form")
    submit_btn.html('处理中 ...').addClass('disabled')
    form.attr(action: "/organizations/#{$scope.current_organization.id}/members/import")
    form.ajaxSubmit
      type: 'POST'
      error: (event, statusText, data, form) ->
        App.alert("上传失败，请重试", 'error')
        submit_btn.html('提交').removeClass('disabled')
      success: (data, statusText, xhr, form) ->
        submit_btn.html('提交').removeClass('disabled')
        $scope.$apply ->
          $scope.members = $scope.members.concat(data.members)
          $scope.fail_memebers = data.meta.unimported_members
]
