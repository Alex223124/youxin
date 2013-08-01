@app.directive "angulartree",["$http",($http)->
  directivecache = 
    restrict: "E"
    scope: 
      datas: "=datas"
      options: "=options"
      selectresult: "=selectresult"
      activeele: "=activeele"
      activeFn: "&"
      insertUrl: "@"
      removeUrl: "@"
    template: """
      <div ng-repeat="data in datas" ng-animate="animate" node-level="{{data.level}}" class="{{$index == 0 ? 'active' : ''}}" ng-click="bindActive(data, $event)" ng-style="{paddingLeft: data.level + \'em\'}">
        <i class="icon-{{_cache[data.selectFlag]}}" ng-show="options.select" ng-click="datas.changeSelectFlag(data, $event)"></i>
        <i class="expand-{{data.expandFlag}} visible-{{!data.isLeafNode}}" ng-show="options.expand" ng-click="bindExpand(data, $event)"></i>
        <span ng-click="bindActive(data, $event)">{{data.name}}<span>({{data.members_count}})</span></span>
        <i class="icon-plus-sign pull-right" ng-show="options.insert" ng-click="bindInsert(data, $event)"></i>
        <i class="icon-remove-sign pull-right" ng-show="options.remove" ng-click="bindRemove(data, $event)"></i>
      </div>
    """
    link: (scope,element,attrs)->
      getActive = ()->
        _cache = if scope.activeele is undefined then scope.datas[0] else scope.activeele
        return _cache

      scope._cache = 
        half: "check-minus"
        true: "check"
        false: "check-empty"

      scope.initialize = ($event)->
        _children = element.children()
        scope.activeele = getActive()
        scope.bindActive(scope.activeele,$event)
        for _i,i in scope.datas
          if _i.level isnt 0
            _children.eq(i).hide()
        element.closest(".pr").prev().unbind("click",scope.initialize)
      element.closest(".pr").prev().bind("click", scope.initialize)

      scope.bindExpand = (data, $event)->
        $event.stopPropagation()
        if not scope.options.expand
          return false
        index = data.index
        scope.datas[index].expandFlag = not data.expandFlag
        currentEle = element.children().eq(index)
        level = data.level
        if data.expandFlag
          currentEle.nextUntil("[node-level='#{level}']","[node-level='#{level+1}']").show()
          i = index + 1
          (()->
            if scope.datas[i].level <= level
              i = scope.datas.length
            else if scope.datas[i].level is level+1
              scope.datas[i].expandFlag = false
            i += 1
            )() while i < scope.datas.length
        else
          subnodeLength = 0
          i = index + 1
          (()->
            if scope.datas[i].level <= level
              subnodeLength = i - index - 1
              i = scope.datas.length
            else
              subnodeLength += 1
            i += 1
            )() while i < scope.datas.length
          currentEle.nextUntil(element.children().eq(index + subnodeLength + 1)).hide()
        
      scope.bindInsert = (data, $event)->
        $event.stopPropagation()
        if not scope.options.insert
          return false
        _index = data.index
        level = data.level
        currentEle = element.children().eq(_index)
        newData = 
          expandFlag: false
          index: _index+1
          isLeafNode: true
          level: level+1
          selectFlag: false 
          name: "undefined"
          id: undefined
          members_count: 0
        data.isLeafNode = false
        scope.datas.splice(_index+1,0,newData)
        i = _index+2
        (()->
          scope.datas[i].index += 1
          i += 1
          )() while i < scope.datas.length
        if not data.expandFlag
          window.setTimeout ()->
            currentEle.children().eq(1).click()
          ,20
        window.setTimeout ()->
          insertEle = element.children().eq(_index+1)
          insertSpan = insertEle.find("span")
          insertSpan.html("<input value='"+newData.name+"' onfocus='this.select()' />")
          insertSpan.find("input").focus()
          insertSpan.find("input").bind("blur",()->
            scope.datas[_index+1].name = insertSpan.find("input").val()
            insertSpan.html(insertSpan.find("input").val())
            $http.post("#{scope.insertUrl}#{data.id}/children",scope.datas[_index+1]).
              success((dat)->
                scope.datas[_index+1].id = dat.id
              ).
              error((data)->
                fixed_alert("添加失败，请重新操作！")
                insertEle.find(".icon-remove-sign").click()
              )
          )
        ,30

      scope.bindRemove = (data, $event)->
        $event.stopPropagation()
        if not scope.options.remove 
          return false

        $http.delete("#{scope.removeUrl}#{data.id}").success((dat)->
          index = data.index
          level = data.level
          console.log(level)
          currentEle = element.children().eq(index)
          if level isnt 0
            i = index-1
            parentNodeIndex = undefined
            (()->
              if scope.datas[i].level is level-1
                parentNodeIndex = i
                i = 0
              i -= 1
            )() while i >= 0
          else
            parentNodeIndex = undefined
          subnodeLength = 0
          i = index+1
          (()->
            if scope.datas[i].level <= level
              subnodeLength = i - index - 1
              i = scope.datas.length
            else
              subnodeLength += 1
            i += 1
          )() while i < scope.datas.length

          scope.datas.splice(index,(subnodeLength+1))
          i = index
          (()->
            scope.datas[i].index = i
            i += 1
          )() while i < scope.datas.length
          if parentNodeIndex is undefined 
            return false
          if parentNodeIndex isnt (scope.datas.length-1)
            if scope.datas[parentNodeIndex].level >= scope.datas[parentNodeIndex+1].level
              scope.datas[parentNodeIndex].isLeafNode = true
          else
            scope.datas[parentNodeIndex].isLeafNode = true
        ).error((data)->
          fixed_alert("删除失败，请重新操作！")
        )


      scope.bindActive = (data, $event)->
        if $event isnt undefined
          $event.stopPropagation()
        if scope.activeFn isnt undefined
          scope.activeFn({org: data})
        else
          _children = element.children()
          _children.eq(scope.activeele.index).removeClass("active")
          _children.eq(data.index).addClass("active")
          scope.activeele = data
]