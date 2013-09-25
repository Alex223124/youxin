UnreadBubble = {}
options      = {}

originalTitle = document.title
currentCount  = 0

defaults =
  text: '【{{num}}条新优信】'
  bubble_selector: '.js-unread-bubble'

getBubbleEle = () ->
  $(options.bubble_selector)

updateTitle = (num) ->
  if num > 0
    text = options.text.replace(/{{.+?}}/, num)
    document.title = "#{text} #{originalTitle}"
  else
    document.title = originalTitle

updateBubble = (num) ->
  if num > 0
    getBubbleEle().html(num)
  else
    getBubbleEle().html('')

UnreadBubble.setOptions = (custom) ->
  for key of defaults
    options[key] = if custom.hasOwnProperty(key) then custom[key] else defaults[key]
  this

UnreadBubble.getCurrentCount = () ->
  currentCount

UnreadBubble.setBubble = (num) ->
  currentCount = parseInt(num)
  updateTitle(currentCount)
  updateBubble(currentCount)
  this

UnreadBubble.setOptions(defaults)
window.UnreadBubble = UnreadBubble
