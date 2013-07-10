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

  $scope.fetch_unread_receipts = (receipt) ->
    post = receipt.post
    unless post.unread_receipts
      $http.get("/posts/#{post.id}/unread_receipts").success((data) ->
        post.unread_receipts = data.unread_receipts
      )

  $scope.fetch_comments = (receipt) ->
    post = receipt.post
    unless post.comments
      $http.get("/posts/#{post.id}/comments").success((data) ->
        post.comments = data.comments
      )

  $scope.favoriteable = (receipt) ->
    if receipt.favorited
      $http.delete("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = false
      )
    else
      $http.post("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = true
      )
  $scope.expandable = (receipt) ->
    receipt.expanded = !receipt.expanded
]