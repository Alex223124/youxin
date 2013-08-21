@app.directive "contenteditable",()->
  return {
    require: "ngModel"
    link: (scope,ele,attrs,ctrl)->
      ele.bind "keyup",()->
        scope.$apply ()->
          ctrl.$setViewValue(ele.text())
      ctrl.$reder = (value)->
        ele.text(value)
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
      member: "=member"
    template: """
      <div ng-transclude></div>
      <div class="options-container">
        <div ng-repeat="option in options" ng-click="setValue(option,$index)"><a href="javascript: void();">{{option.name}}</a></div>
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
        if value is undefined or value is null
          index = 0
        else
          index = scope.options.indexOfProperty("id",value.id)
        scope.model = value
        optionsContainer.children(".active").removeClass("active")
        optionsContainer.children("div").eq(index).addClass("active")
        element.unbind "click",initialize

      scope.setValue = (option,index)->
        success = true
        if scope.callback isnt undefined
          success = scope.callback({newOption: option, member: scope.member,oldOption: scope.model})
        if success
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
