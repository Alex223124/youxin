@SettingsController = ["$scope", "$http",($scope, $http)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
  ]

  $scope.setActive = (navs, name) ->
    if navs
      for nav in navs
        if nav.name is name
          nav.class = 'active'
        else
          nav.class = ''

  $scope.prepare_breadcrumbs = (n) ->
    $scope.breadcrumbs.splice(n)

]
