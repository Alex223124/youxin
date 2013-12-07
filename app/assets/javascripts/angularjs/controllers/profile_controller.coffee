@profileController = ["$scope", "$http", ($scope, $http)->
  $scope.breadcrumbs = [
    {
      name: '首页'
      url: '/'
    }
    {
      name: '个人主页'
      url: '/user/organizations'
    }
  ]
  getUserInformations = (callback, callbackerror)->
    $http.get("/account.json").success (data, _status)->
      callback(data.user, _status)
    .error (_data, _status)->
      callbackerror(_data, _status)

  getCurrentUserOrganizations = (callback, callbackerror)->
    $http.get("/account/organizations.json").success (_data)->
      callback(_data.organizations)
    .error (_data, _status)->
      callbackerror(_data, _status)
      App.alert("获取我所在的组织失败!", 'error')

  getCreatedReceipts = (callback,callbackerror)->
    $http.get("/account/created_receipts.json").success (_data,_status)->
      callback(_data.created_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getFavoritedReceipts = (callback,callbackerror)->
    $http.get("/account/favorited_receipts.json").success (_data,_status)->
      callback(_data.favorited_receipts,_status)
    .error (_data,_status)->
      callbackerror(_data,_status)

  getUserInformations (_data)->
    $scope.user = _data
  ,(_data,_status)->
    App.alert("获取信息失败!", 'error')

  getCurrentUserOrganizations (_data)->
    $scope.organizations = _data

  $scope.refreshFavoritedReceipts = ()->
    getFavoritedReceipts (_data)->
      $scope.favorited_receipts = _data
    ,(_data,_status)->
      App.alert("获取收藏的消息失败！", 'error')

  $scope.refreshCreatedReceipts = ()->
    getCreatedReceipts (_data)->
      $scope.created_receipts = _data
    ,(_data,_status)->
      App.alert("获取发布的消息失败！", 'error')

  $scope.refreshCreatedReceipts()
  $scope.refreshFavoritedReceipts()


  $scope.init_form_height = (receipt)->
    created_receipt_height = if $("\##{receipt.id}-created_receipts-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-created_receipts-forms").css("height",created_receipt_height)
    favorited_height = if $("\##{receipt.id}-favorited_receipts-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-favorited_receipts-forms").css("height",favorited_height)

  $scope
]