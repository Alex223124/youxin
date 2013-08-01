@uploaderController = ["$scope", ($scope)->
  $scope.results = (content, completed) ->
    if completed and content.length > 0
      console.log(content)
    else
      # // 1. ignore content and adjust your model to show/hide UI snippets; or
      # // 2. show content as an _operation progress_ information
]