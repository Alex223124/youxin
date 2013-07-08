@ReceiptsController = ($scope, $http) ->
  $http.get('/receipts.json').success((data) ->
    $scope.receipts = data.receipts
  )

  $scope.fetch_attachments = (post) ->
    unless post.attachments
      $http.get("/posts/#{post.id}/attachments").success((data) ->
        post.attachments = data.attachments
      )