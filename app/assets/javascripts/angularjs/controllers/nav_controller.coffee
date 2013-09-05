@navController = ['$scope', '$location', ($scope, $location) ->
  $scope.isActive = (route_info) ->
    return 'active' if route_info is $location.path()
    if route_info is '/admin/organizations'
      reg = ////admin/organizations/[a-f0-9]+$///
      return 'active' if reg.test $location.path()
    if route_info is '/organizations'
      reg = ///^/organizations/[a-f0-9]+$///
      return 'active' if reg.test $location.path()
    if route_info is '/organization_members'
      reg = ////organizations/[a-f0-9]+/members$///
      return 'active' if reg.test $location.path()
    if route_info is "/notifications"
      reg = ////notifications|/bills///
      return "active" if reg.test $location.path()
]
