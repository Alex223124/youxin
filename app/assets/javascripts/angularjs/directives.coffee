@app.directive "contenteditable",()->
  return {
    require: "ngModel"
    link: (scope,ele,attrs,ctrl)->
      ele.bind "keyup",()->
        scope.$apply ()->
          ctrl.$setViewValue(ele.html())
      ctrl.$reder = (value)->
        ele.html(value)
      #ctrl.$setViewValue(ele.html())
  }

@app.directive 'ngBlur',()-> 
  return {
    restrict: 'A'
    link: (scope, element, attrs)->
      element.bind 'blur',()->
        scope.$apply(attrs.ngBlur)
  }

@app.directive "radioselect", ["$document",($document)->
  directiveCache = 
    restrict: "A"
    transclude: true
    scope:
      options: "=options"
      callback: "&"
      model: "=ngModel"
    template: """
      <div ng-transclude></div>
      <div class="options-container">
        <div ng-repeat="option in options" ng-click="setValue(option,$index)"><a href="javascript: void();">{{option}}</a></div>
        <span class="caret-up"></span>
      </div>
    """
    link: (scope,element,attrs)->
      element.css
        position: "relative"
        cursor: "pointer"
      optionsContainer = element.children().eq(1)
      optionsContainer.css
        position: "absolute"
        zIndex: "-1"
        top: "60%"
        left: "0"
        opacity: 0
        filter: "alpha(opacity=0)"
        MsFilter: "alpha(opacity=0)"
        width: element.width()
        MozTransition: "all .3s ease-in-out"
        WebkitTransition: "all .3s ease-in-out"
        MsTransition: "all .3s ease-in-out"
        OTransition: "all .3s ease-in-out"
        transition: "all .3s ease-in-out"
      showContainer = ()->
        optionsContainer.css
          top: "125%"
          opacity: 1
          filter: "alpha(opacity=100)"
          MsFilter: "alpha(opacity=100)"
          zIndex: "10000"
      hideContainer = ()->
        optionsContainer.css
          top: "60%"
          filter: "alpha(opacity=0)"
          MsFilter: "alpha(opacity=0)"
          opacity: 0
          zIndex: "-1"
        $document.unbind "click", hideContainer
      initialize = ()->
        value = scope.model
        index = 0
        for _option,_i in scope.options
          if _option is value
            index = _i
            break
        scope.setValue(value,index)
        element.unbind "click",initialize
      scope.setValue = (option,index)->
        scope.model = option
        optionsContainer.children(".active").removeClass("active")
        optionsContainer.children("div").eq(index).addClass("active") 
      element.bind "click", ($event)->
        $event.stopPropagation()
        if optionsContainer.css("z-index") is "-1"
          showContainer()
          $document.bind "click",hideContainer
        else
          hideContainer()
      element.bind "click",initialize
  directiveCache
]

@app.directive "draggable",["$document",($document)->
  startX = 0
  startY = 0
  x = y = 0
  return (scope,element,attrs)->
    if element.css("position") is "absolute"
      element.css 'position','absolute'
    else if element.css('position') is "fixed"
      element.css 'position','fixed'
    else
      element.css({
        position: "relative"
      })

    element.css({
      cursor : "pointer"
    })
    x = if (element.css('left') is undefined) then x else parseInt(element.css('left'))
    y = if (element.css('top') is undefined) then y else parseInt(element.css('top'))
    element.bind "mousedown",(event)->
      startX = event.screenX - x
      startY = event.screenY - y
      $document.bind("mousemove",mousemove)
      $document.bind("mouseup",mouseup)
    mousemove = (event)->
      y = event.screenY - startY
      x = event.screenX - startX
      element.css({
        top : y + "px"
        left: x + "px"
      })
    mouseup = ()->
      $document.unbind('mousemove', mousemove)
      $document.unbind('mouseup', mouseup)
]

@app.directive "idcard",()->
  idcardobj = 
    restrict: "A"
    transclude: true
    scope:
      src: "@url"
      name: "@name"
      position: "@position"
      phonenumber: "@phonenumber"
      info: "=info"
      orglist: "@orglist"

    template: '<div class="id-card"><div class="card-top"><img class="pull-right" ng-src="src" alt="user-picture">'+
      '<li><span class="name">{{name}}</sapn>(<span class="position">{{position}}</span>)</li>'+
      '<li>Tel:<span class="phonenumber">{{phonenumber}}</span></li>'+
      '</div><div class="card-down"><li><span>info:</span><span contenteditable="true" ng-model="info"></span></li>'+
      '<li><span>org:</span><span><span ng-repeat="org in orglist">{{org.name}}</span></span></li>'+
      '<i class="icon icon-caret-down border"></i><i class="icon icon-caret-down background"></i></div></div>'+
      '<span ng-transclude><span>'
  idcardobj

@app.directive "dragY",["$document",($document)->
  startY = 0
  y = 0
  directiveCache = 
    require: "scrollbarShow"
    link: (scope,ele,attrs,ctrl)->
      if ele.css("position") is "absolute"
        ele.css 'position','absolute'
      else if ele.css('position') is "fixed"
        ele.css 'position','fixed'
      else
        ele.css({
          position: "relative"
        })
      ele.css({
        cursor: "pointer"
      })
      y = if ele.css("top") is undefined then y else parseInt(element.css('top'))
      ele.bind "mousedown",(event)->
        startY = event.screenY - y
        $document.bind("mousemove",mousemove)
        $document.bind("mouseup",mouseup)
      mousemove = (event)->
        y = event.screenY - startY
        ele.css({
          top: y + "px"
        })
      mouseup = ()->
        $document.unbind('mousemove', mousemove)
        $document.unbind('mouseup', mouseup)  
  return directiveCache    
]

@app.directive "dragX",["$document",($document)->
  startX = 0
  x = 0
  return (scope,ele,attrs)->
    if ele.css("position") is "absolute"
      ele.css 'position','absolute'
    else if ele.css('position') is "fixed"
      ele.css 'position','fixed'
    else
      ele.css({
        position: "relative"
      })
    ele.css({
      cursor: "pointer"
    })
    x = if ele.css("top") is undefined then x else parseInt(element.css('top'))
    ele.bind "mousedown",(event)->
      startX = event.screenX - x
      $document.bind("mousemove",mousemove)
      $document.bind("mouseup",mouseup)
    mousemove = (event)->
      x = event.screenX - startX
      ele.css({
        top: x + "px"
      })
    mouseup = ()->
      $document.unbind('mousemove', mousemove)
      $document.unbind('mouseup', mouseup)      
]

@app.directive "scrollY",()->
  top = 0
  height = 0
  directiveCache =
    transclude: true
    template: """
      <div class="scrollbar">
        <div class="scrollbar-bg">
          <div></div>
        </div>
      </div>
      <div ng-transclude></div>
    """
    link: (scope,element,attrs)->
      element.css(
        overflowY : "hidden"
        cursor    : "default"
      )
      userAg = navigator.userAgent.toLowerCase()
      #mousewheel in ff is DOMMouseScroll
      eventType = if ///firefox///.test(userAg) then "DOMMouseScroll" else "mousewheel"
      element.bind eventType,(event)->
        event = event.originalEvent
        detail = if event.wheelDelta then event.wheelDelta/2 else -20*event.detail
        height = element.height()
        child = element.children()
        contentHeight = child.height()
        top = parseInt child.css("margin-top")
        if (detail>0)
          detail = if (top>-detail) then -top else detail
        if (detail<0)
          detail = if ((contentHeight+top-height)<-detail) then (height-top-contentHeight) else detail
        #make sure than element can scroll
        if (contentHeight>height) 
          child.css("margin-top",(top+detail)+"px")
  return directiveCache


@app.directive "scrollWithScrollBar",["$document",($document)->
  startY = 0
  y = 0
  directiveCache =
    transclude: true
    template:""" 
      <div class="_scroll-wrap" ng-transclude></div>  
      <div class="_scroll-bar">
        <div class="_bar-pr">
          <div class="_bar-block"></div>
        </div>
      </div>
    """
    link: (scope,element,attrs)->
      element.css(
        overflowY : "hidden"
        cursor    : "pointer"
        position  : "relative"
      )
      userAg = navigator.userAgent.toLowerCase()
      eventType = if ///firefox///.test(userAg) then "DOMMouseScroll" else "mousewheel"
      domele = posData = {}
      domele.scrollView = element
      domele.scrollWrap = element.children().first()
      domele.scrollBarWrap = element.children().last()
      domele.scrollBarBlock = domele.scrollBarWrap.find("._bar-block")
      posData.viewHeight = domele.scrollView.height()
      posData.contentHeight = domele.scrollWrap.height()
      posData.top = parseInt(domele.scrollWrap.css('margin-top'))
      posData.scrollBarRatio = posData.viewHeight / posData.contentHeight
      posData.scrollBarBlockHeight = parseInt(posData.viewHeight * posData.scrollBarRatio)
      posData.scrollBlockTop = -parseInt(posData.top * posData.scrollBarRatio)
      domele.scrollWrap.css("margin-top","0px")
      domele.scrollBarBlock.css("margin-top","0px")
      domele.scrollBarWrap.css(
        height: posData.viewHeight
        position: "absolute"
      )
      domele.scrollBarWrap.children().css(
        position: "relative"
      )
      domele.scrollBarBlock.css(
        position: "relative"
        height: posData.scrollBarBlockHeight
        MozUserSelect: "none"
        MsUserSelect: "none"
        WebkitUserSelect: "none"
        userSelect: "none"
      )
      element.bind eventType,(event)->
        event = event.originalEvent
        detail = if event.wheelDelta then event.wheelDelta else -40*event.detail
        posData.viewHeight = domele.scrollView.height()
        posData.contentHeight = domele.scrollWrap.height()
        posData.top = parseInt(domele.scrollWrap.css('margin-top'))
        delta = 0
        if posData.contentHeight <= posData.viewHeight
          return true
        if detail > 0
          delta = if (posData.top > -detail) then -posData.top else detail 
        else
          delta = if ((posData.contentHeight+posData.top-posData.viewHeight) < -detail) then (posData.viewHeight-posData.top-posData.contentHeight) else detail
        domele.scrollWrap.animate({marginTop: (posData.top+delta)+"px"},100,"linear")
        posData.scrollBarRatio = posData.viewHeight / posData.contentHeight
        posData.scrollBarBlockHeight = parseInt(posData.viewHeight * posData.scrollBarRatio)
        posData.scrollBlockTop = -parseInt((posData.top + delta) * posData.scrollBarRatio)
        domele.scrollBarBlock.animate(
          height: posData.scrollBarBlockHeight
          top: posData.scrollBlockTop
        ,100,"linear")
      domele.scrollBarWrap.bind "mousedown",(event)->
        top = parseInt(domele.scrollBarBlock.css("top"))
        toolBarHeight = window.outerHeight - window.innerHeight
        delta = event.screenY - domele.scrollBarBlock.offset().top - toolBarHeight
        top += delta
        top = if top < (posData.viewHeight - posData.scrollBarBlockHeight) then top else (posData.viewHeight - posData.scrollBarBlockHeight)
        domele.scrollBarBlock.animate(
          top : top 
        ,100,"linear")
        posData.scrollBlockTop = top
        posData.top = -parseInt(posData.scrollBlockTop / posData.scrollBarRatio)
        posData.top = if posData.top > (posData.viewHeight - posData.contentHeight) then posData.top else -(posData.contentHeight - posData.viewHeight)
        domele.scrollWrap.animate(
          marginTop: posData.top 
        ,100,"linear")
  return directiveCache
]
