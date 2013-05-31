@ReceiptsController = ($scope, $http) ->
  $http.get('/receipts.json').success((data) ->
    $scope.unread_receipts = data
  )