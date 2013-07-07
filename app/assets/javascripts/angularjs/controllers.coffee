@ReceiptsController = ($scope, $http) ->
  $http.get('/receipts.json').success((data) ->
    $scope.receipts = data.receipts
  )