@ReceiptsController = ['$scope', '$http', 'Receipt', ($scope, $http, Receipt) ->
  $scope.receipts = Receipt.query()

  $scope.fetch_attachments = (receipt) ->
    post = receipt.post
    unless post.attachments
      receipt.attachments_loading = true
      $http.get("/posts/#{post.id}/attachments").success((data) ->
        receipt.attachments_loading = false
        post.attachments = data.attachments
      )
]