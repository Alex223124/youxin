@app.factory "conversationService", ["$http", ($http)->
  serviceCache = {}
  #get the history
  serviceCache.getConversations = ()->
    $http.get("url").success (data, status)->
      serviceCache.conversations = data
    .error (data, status)->
      unless serviceCache.conversations
        serviceCache.conversations = []
      console.log "failed to require conversations"

  serviceCache.getNewConversation = (ids, data)->
    _data = {}
    _data.ids = ids
    $http.post("", _data).success (data, status)->
      serviceCache.newConversation = data
    .error (data, status)->
      unless serviceCache.newConversation
        serviceCache.newConversation = {}
      console.log "failed to require the new conversation"
]