#使用时作为属性使用，值为angularjs变量

@app.directive "timeago", ["$timeout", ($timeout)->
  directiveCache = 
    restrict: "A"
    scope:
      created_at: "=timeago"
    link: (scope, element, attrs)->
      timeline = 
        onesecond: 1000
        oneminute: 60 * 1000
        anhour: 60 * 60 * 1000
        oneday: 24 * 60 * 60 * 1000
        onemonth: 30 * 24 * 60 * 60 * 1000
        oneyear: 365 * 24 * 60 * 60 * 1000

      getTimeAgo = (datastr)->
        now = new Date()
        timeStr = $.trim(datastr)
        timeStr = timeStr.replace(/\.\d+/,"")
        timeStr = timeStr.replace(/-/,"/").replace(/-/,"/")
        timeStr = timeStr.replace(/T/," ").replace(/Z/," UTC")
        timeStr = timeStr.replace(/([\+\-]\d\d)\:?(\d\d)/," $1$2")
        _created_at = new Date(timeStr)
        return (now.getTime() - _created_at.getTime())

      getTimeStep = (datenumber)->
        if datenumber > timeline.anhour
          return false
        else if datenumber > timeline.oneminute
          return timeline.oneminute
        else return timeline.onesecond

      getHtmlStr = (datenumber)->
        if datenumber <= 0
          return "刚刚"
        else if datenumber < timeline.oneminute
          return "#{parseInt(datenumber / timeline.onesecond)}秒前"
        else if datenumber < timeline.anhour
          return "#{parseInt(datenumber / timeline.oneminute)}分钟前"
        else if datenumber < timeline.oneday
          return "#{parseInt(datenumber / timeline.anhour)}小时前"
        else if datenumber < timeline.onemonth
          return "#{parseInt(datenumber / timeline.oneday)}天前"
        else if datenumber < timeline.oneyear
          return "#{parseInt(datenumber / timeline.onemonth)}月前"
        else if datenumber < 5 * timeline.oneyear
          return "#{parseInt(datenumber / timeline.oneyear)}年前"
        else
          return "太久了"
   
      main = ()->
        timeAgo = getTimeAgo(scope.created_at)
        timeoutStep = getTimeStep (timeAgo)
        resultStr = getHtmlStr(timeAgo)
        element.text(resultStr)
        if timeoutStep
          $timeout(main, timeoutStep)

      main()
  return directiveCache
]