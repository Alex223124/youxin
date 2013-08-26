@app.factory "organizationServices", ["$http",($http)->
  serviceCache = {}

  #private
  initial = (method, url, data, success, error)->
    $http[method](url, data).success (data, status)->
      if success
        success(data, status)
    .error (data, status)->
      if error
        error(data, status)

  #public

  #获取所有组织
  serviceCache.getAllOrganizations = (success, error)->
    initial("get", "/organizations.json", "", success, error)

  #获取我所在的组织
  serviceCache.getUserOrganizations = (success, error)->
    initial("get", "/account/organizations.json", "", success, error)

  #获取指定组织的成员
  serviceCache.getOrganizationMembers = (org_id, success, error)->
    initial("get", "/organizations/#{org_id}/members.json", "", success, error)

  #获取指定组织的管理员
  serviceCache.getOrganizationManagers = (org_id, success, error)->
    initial("get", "/organizations/#{org_id}/authorized_users.json", "", success, error)

  #删除某个组织的某些成员
  serviceCache.deleteOrganizationMembers = (org_id, members_ids, success, error)->
    initial("delete", "/organizations/#{org_id}/members.json", members_ids, success, error)


  return serviceCache
]