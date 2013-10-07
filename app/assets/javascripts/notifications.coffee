#= require faye/faye-browser
#= require notifier
window.Youxin =
  notifier: new Object

  initNotificationSubscribe : () ->
    Youxin.notifier = new window.Notifier
    if CURRENT_USER_NOTIFICATION_CHANNEL isnt ''
      faye = new Faye.Client(FAYE_SERVER_URL)
      channel = "/#{SUBSCRIPTION_PREFIX}/#{CURRENT_USER_NOTIFICATION_CHANNEL}"
      faye.subscribe channel, (data) ->
        json = data.json
        if json.message?
          data = json.message
          title = "#{data.user.name}向您发送了一条私信"
          body = "#{data.body}"
          avatar_url = data.user.avatar_url
          id = data.conversation.id
          # url = Youxin.fixUrlDash("#{ROOT_URL}/conversations/#{data.conversation.id}")
        else if json.receipt?
          data = json.receipt
          title = data.post.title
          avatar_url = data.author.avatar_url
          body = "#{data.author.name}:\n#{data.body}"
          id = data.id
          # url = Youxin.fixUrlDash("#{ROOT_URL}/posts/#{data.id}")
        else if json.comment_notification?
          data = json.comment_notification
          title = "#{data.comment.user.name} 评论了你的优信 【#{data.comment.commentable.body}】"
          body = "#{data.comment.body}"
          avatar_url = data.comment.user.avatar_url
        else if json.organization_notification?
          data = json.organization_notification
          title = "组织状态改变"
          if data.status is 'in'
            body = "你被移入了 #{data.organization.name}"
          else
            body = "你被移除了 #{data.organization.name}"
          avatar_url = data.organization.avatar_url

        if title
          avatar = Youxin.fixUrlDash("#{ROOT_URL}#{Youxin.getAvatarVersion(avatar_url, 'small')}")
          if id
            Youxin.notifier.notify(avatar, title, body, id)
          else
            Youxin.notifier.notify(avatar, title, body)
        Youxin.updateNotificationsCounter()

  fixUrlDash : (url) ->
    url.replace(/\/\//g,"/").replace(/:\//,"://")

  getAvatarVersion : (url, version) ->
    return '' unless url
    array = url.split('/')
    array[array.length - 1] = "#{version}_#{array.last()}"
    array.join('/')

  # update Title and Bubble
  updateNotificationsCounter : () ->
    $.get '/account/notifications_counter', (data) ->
      receipts = data.receipts
      UnreadBubble.setBubble(receipts)

