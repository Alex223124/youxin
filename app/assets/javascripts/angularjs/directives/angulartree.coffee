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
      
      # TODO :待处理  
      scope.bindInsert = (data, $event)->
        $event.stopPropagation()
        if not scope.options.insert
          return false

        tpl = """
          <div class="modal">
            <div class="modal-header">
              <button type="button" class="close cancel" data-dismiss="modal" aria-hidden="true">&times;</button>
              <h4>在&nbsp;<span>#{data.name}</span>&nbsp;下新建组织</h4>
            </div>
            <div class="modal-body">
              <p>
                <input type="text" class="input" placeholder="请输入组织名称">
              </p>
            </div>
            <div class="modal-footer">
              <a href="javascript:;" class="btn cancel">取消</a>
              <a href="javascript:;" class="btn btn-primary submit">创建</a>
            </div>
          </div>
        """
        popwindow = $("<div class='popwindow'>")
        mask = $("<div class='mask cancel'>")
        content = $("<div class='content'>")
        content.append(tpl)
        popwindow.append(mask).append(content)
        $(document.body).append(popwindow)

        content = popwindow.find(".content") 
        content.css
          left: ($(document.body).width() - content.width())/2
          top: (window.innerHeight - content.height())/2

        popwindowhide = ()->
          popwindow.find(".cancel").unbind "click", popwindowhide
          popwindow.find('input').unbind "keydown", keybind
          popwindow.remove()
 
        submit = ()->
          _data =
            organization:
              name: popwindow.find("input").val()
          $.post("#{scope.insertUrl}#{data.id}/children", _data).success (_data, _status)->
            new Organization(_data.organization)
            Organization.setIndex(false)
            Organization.setExpandFlag(true)
            scope.$apply ->
              scope.datas = Organization.all
              popwindow.find("a.submit").unbind "click", submit
            fixed_alert("添加成功")
            popwindowhide()
          .error (_data, _status)->
            fixed_alert("添加失败，请重新操作！")
            popwindowhide()

        keybind = (event)->
          if event.keyCode is 13
            submit()

        popwindow.find("input").focus().val("")
        popwindow.find(".cancel").bind "click", popwindowhide

        popwindow.find("a.submit").bind "click", submit
        popwindow.find('input').bind "keydown", keybind


      scope.bindRemove = (data, $event)->
        $event.stopPropagation()
        if not scope.options.remove 
          return false

        tpl = """
          <div class="modal">
            <div class="modal-header">
              <button type="button" class="close cancel" data-dismiss="modal" aria-hidden="true">&times;</button>
              <h4>确认删除&nbsp;<span>#{data.name}</span></h4>
            </div>
            <div class="modal-footer">
              <a href="javascript:;" class="btn cancel">取消</a>
              <a href="javascript:;" class="btn btn-primary submit">删除</a>
            </div>
          </div>
        """
        confirm = $("<div class='confirm'>")
        content = $("<div class='content'>")
        content.append(tpl)
        confirm.append(content)
        $(document.body).append(confirm)
        content = confirm.find(".content")
        content.css
          left: event.clientX - content.width()/2
          top: if (event.clientY - content.height() - 20) < 0 then event.clientY + 20 else  event.clientY - content.height() - 20

        hideconfirm = ()->
          confirm.find(".cancel").unbind "click", hideconfirm
          confirm.find("a.submit").unbind "click", submit
          confirm.remove()

        confirm.find(".cancel").bind "click", hideconfirm
        index = data.index
        level = data.level
        currentEle = element.children().eq(index)
        parentNode = data.parent
        if parentNode.length > 0
          parentNodeIndex = parentNode.index
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
        #jquery没有delete方法
        submit = ()->
          $http.delete("#{scope.removeUrl}#{data.id}").success (_data)->
            scope.datas.splice(index,(subnodeLength+1))
            i = index
            (()->
              scope.datas[i].index = i
              i += 1
            )() while i < scope.datas.length
            if parentNodeIndex isnt (scope.datas.length-1)
              if scope.datas[parentNodeIndex].level >= scope.datas[parentNodeIndex+1].level
                scope.datas[parentNodeIndex].isLeafNode = true
            else
              scope.datas[parentNodeIndex].isLeafNode = true
            hideconfirm()
          .error (data)->
            fixed_alert("删除失败，请重新操作！")
            hideconfirm()


        confirm.find("a.submit").bind "click", submit


        ###$http.delete("#{scope.removeUrl}#{data.id}").success((dat)->
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
        )###


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