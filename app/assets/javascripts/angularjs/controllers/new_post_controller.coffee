@formcreateCtrl = ["$scope","$http", "$filter",(scope,http, $filter)->
  controllerElement = $("#table-edit")
  scope.form_json = 
    title: "未命名"
    fieldlist: []

  activeEle = undefined
  setActiveFiled = (index)->
    if activeEle isnt undefined
      activeEle.removeClass("active")
    activeEle = controllerElement.children("ul").find("._scroll-wrap").children().eq(index).addClass("active")

  scope.setFocusFiled = ()->
    scrollWrap = controllerElement.children("ul").find("._scroll-wrap")
    barBlock = scrollWrap.next()
    viewHeight = controllerElement.children("ul").height()
    scrollWrapTop = scrollWrap.height() - viewHeight
    scrollWrapTop = if scrollWrapTop < 0 then 0 else scrollWrapTop
    scrollWrap.css(
      marginTop: -scrollWrapTop
    )
    barBlockHeight = viewHeight*viewHeight / scrollWrap.height()

  scope.addNewFiled = (type)->
    fieldcache = 
      _type: type
      label: "未命名"
      help_text: ""
      required: false
      default_value: ""
      index: scope.form_json.fieldlist.length
    if type is "radio" or type is "checkbox"
      fieldcache.options = [
        {
          _type: "option"
          selected: false
          value: "选项"
        }
      ]
    scope.form_json.fieldlist.push(fieldcache)
    setTimeout(()->
      setActiveFiled(fieldcache.index)
      scope.setFocusFiled()
    ,10)
    @setEditField(fieldcache)

  scope.addNewOption = (field)->
    field.options.push({
      _type: "option"
      selected: false
      value: "选项"+scope.editfield.options.length
    })

  scope.removeOption = (option)->
    options = scope.editfield.options
    index = options.indexOfProperty("value",option.value)
    options.splice(index,1)
    if options.length is 0
      options.push({
        _type: "option"
        selected: false
        value: "选项"
      })

  scope.isRadio = (field)->
    return (if field._type is "radio" then true else false)
  scope.hasOptions = (field)->
    return (if field.options is undefined then false else true)
  scope.isCheckbox = (field)->
    return (if field._type is "checkbox" then true else false)
  scope.isTextarea = (field)->
    return (if field._type is "textarea" then true else false)

  scope.isnull = ()->
    editfield = scope.editfield
    return (editfield._type == undefined)

  scope.editfield = {}


  scope.setEditField = (field)->
    if field is undefined
      field = {}
    scope.editfield = field
    index = scope.form_json.fieldlist.indexOfProperty("index",field.index)
    setActiveFiled(index)

  scope.removeField = ()->
    field = scope.form_json.fieldlist
    index = field.indexOfProperty("index",scope.editfield.index)
    field.splice(index,1)
    scope.editfield = {}
    setTimeout(()->
      scope.setFocusFiled()
    ,10)

  scope.error_flag = false
  scope.error_type = "有相同选项！"
  scope.check_title = ()->
    scope.error_flag = not scope.editfield.label
    scope.error_type = "标题不能为空！"
  scope.check_uniq = (value) ->
    if scope.editfield.options.hasTwoInArrayOfProperty("value", value)
      scope.error_flag = true
      scope.error_type = "有相同选项！"
    else
      scope.error_flag = false

  scope.saveForm = ()->
    form_json = 
      form: $filter('format_form_json')(scope.form_json)
    # console.log form_json
    http(
      data: form_json
      url: "/forms"
      method: "POST"
    ).success((data)->
      #hthnstnh
      form = data.form
      scope.formData.name = form.title
      scope.formData.id = form.id 
      scope.youxindata.form_ids = [form.id]     
      controllerElement.hide(200)
      App.alert("表格 [#{scope.form_json.title}] 保存成功")
    ).error((data)->
      App.alert("表格 [#{scope.form_json.title}] 保存失败!", 'error')
    )
  scope.$on "clearData",()->
    scope.formData.name = ""
    scope.youxindata.form_ids = []
]

@NewPostsController = ["$scope","$http","$location",($scope,$http,$location)->
  $scope.toggleTableEdit = ()->
    targetele = $("#table-edit")
    ishidden = targetele.css("display") is "none"
    if ishidden
      targetele.show(200)
    else
      targetele.hide(200)

    false
  $scope.inputtypelist = [
    {
      iconname: "icon-email"
      name: "text"
      type: "text"
    }
    {
      iconname: "icon-email"
      name: "textarea"
      type: "textarea"
    }
    {
      iconname: "icon-email"
      name: "number"
      type: "text"
    }
    {
      iconname: "icon-email"
      name: "checkbox"
      type: "checkbox"
    }
    {
      iconname: "icon-email"
      name: "radio"
      type: "radio"
    }  
  ]
  $scope.youxindata = 
    title: ""
    body_html: ""
    organization_ids: []
    delayed_sms_at: ''
    form_ids: []
    attachment_ids: []

  $scope.$on "attachment_change", (event,data)->
    $scope.youxindata.attachment_ids = []
    for _i in data.attachments
      $scope.youxindata.attachment_ids.push _i.id 

  $scope.formData =
    name: ""
    id: []
  $scope.remove_form = ()->
    $scope.formData.name = ""
    $scope.formData.id = []

  $scope.goto = (next,str1,str2)->
    self = $("#send-msg").find(str1)
    if next is "prev" or (self.find(".nextStep").attr("disabled") is undefined)
      targetele = self.closest(".write-steps").find(str2)
      self.closest(".js-steps").hide()
      targetele.fadeIn(200)
  
  #$scope.$on "formReady",()->
  $scope.submit = ()->
    # console.log($scope.youxindata)
    $http(
      url: "/posts.json"
      method: "POST"
      data: $scope.youxindata
    ).success(()->
      $scope.$broadcast("clearData")
      App.alert("消息已成功发送")
      $location.url("/")
      Organization.all = []
    )
]

@firststepCtrl = ["$scope",($scope)->
  $scope.msgtitle = ""
  $scope.content = ""
  timeInterval = undefined
  $scope.form_valid = true
  $scope.valid = ()->
    $scope.content = $("#wysihtml5-textarea").val()
    $scope.form_valid = (not $scope.msgtitle) or (not $scope.content)
  $scope.collectData = ()->
    $scope.youxindata.title = this.msgtitle
    $scope.youxindata.body_html = $("#wysihtml5-textarea").val()
    self = $("#send-msg").find(".first-step")
    # console.log $scope.youxindata 
    window.setTimeout(()->
      if (self.find(".nextStep").attr("disabled") is undefined)
        targetele = self.closest(".write-steps").find(".second-step")
        self.closest(".js-steps").hide()
        targetele.fadeIn(200)
    ,10)

  $scope.$on "clearData",()->
    $scope.msgtitle = ""
    $scope.content = ""
    $("#wysihtml5-textarea").val("")
]

@secondstepCtrl = ["$scope", '$http', "$document",(scope, $http ,$document)->
  $http.get('/user/authorized_organizations.json?actions[]=create_youxin').success((data) ->
    Organization.all = []
    for organization in data.authorized_organizations
      new Organization(organization)
    Organization.setIndex(true)
    scope.activeele = Organization.getAncestors().first()
    scope.authorized_organizations = Organization.all
    scope.authorized_organizations.changeSelectFlag = (data, $event)->
      changeSelect = (data, $event)->
        $event.stopPropagation()
        self = this
        index = data.index
        level = data.level
        selected = if data.selectFlag is true then true else false
        _children = (index,level)->
          _result = []
          i = index+1
          (()->
            _obj = self[i]
            if _obj.level > level
              _result.push(_obj)
            else
              i = self.length
            i += 1 
            )() while i < self.length
          return _result
        _parent = (index,level)->
          _result = null
          if level is 0
            return null
          i = index-1
          (()->
            _obj = self[i]
            if _obj.level is level-1
              _result = _obj
              i = 0
            i -= 1 
            )() while i >= 0
          return _result
        _checkSelect = (flag,arr)->
          for i in arr
            if i.selectFlag is flag
               return true
          return false
        children = _children(index,level)
        data.selectFlag = not selected
        for i in children
          i.selectFlag = not selected
        ((_index,_level)->
          parent = _parent(_index,_level)
          if parent is false or parent is null
            return false
          else
            siblings = _children(parent.index,parent.level)
            hasSelected = _checkSelect(selected,siblings)
            if hasSelected
              (()->
                parent.selectFlag = "half"
                parent = _parent(parent.index,parent.level)
                )() while parent isnt false and parent isnt null
            else
              parent.selectFlag = not selected
              arguments.callee(parent.index,parent.level)
          )(index,level)
        _result = []
        for i in self
          if i.selectFlag is true and not _result.isInArrayOfProperty("id",i.id)
            _result.push(i)
        scope.selectresult = _result
      changeSelect.call(scope.authorized_organizations,data,$event)
  )

  scope.options =
    insert: false
    remove: false
    expand: true
    select: true
  scope.selectresult = []
  scope.present_organizations = []
  scope.selected_organization_ids = []
  $http.get("/user/recent_authorized_organizations.json").success((data)->
    #data.organization_ids
    #data.organization_clan_ids
    scope.commonly_used_organizations = data
    scope.present_commonly_used_organizations = (()->
      _result = []
      for _id in scope.commonly_used_organizations.organization_clan_ids
        _result.push scope.authorized_organizations.objOfProperty("id","parentNode-#{_id}")
      for _id in scope.commonly_used_organizations.organization_ids
        _result.push scope.authorized_organizations.objOfProperty("id",_id)
      _result
    )()
  )
  scope.$watch("selectresult",(selected_orgs)->
    scope.present_organizations = []
    scope.selected_organization_ids = []
    for organization in selected_orgs
      scope.present_organizations.push organization
    for organization in selected_orgs
      unless organization.isLeafNode
        scope.present_organizations.remove(organization.children)
      else
        scope.selected_organization_ids.push organization.id
  )

  scope.toggleOrgList = ($event)->
    $event.stopPropagation()
    $("#select-org-container").children(".pr").toggle()

  $document.bind("click",()->
    $("#select-org-container").children(".pr").hide()    
  )

  ###scope.msgtitle = ""
  scope.valid = ()->
    return (not this.msgtitle)###
  scope.collectData = ()->
    #for _id in scope.selected_organization_ids
    scope.youxindata.organization_ids = scope.selected_organization_ids 
      #= scope.youxindata.organization_ids.concat($(org).attr("targetid").split(","))
    self = $("#send-msg").find(".second-step")
    if (self.find(".nextStep").attr("disabled") is undefined)
      targetele = self.closest(".write-steps").find(".third-step")
      self.closest(".js-steps").hide()
      targetele.fadeIn(200)  
  scope.$on "clearData",()->
    selected_orgs = $("#select-org-container").find(".selected-org-item")
    for org in selected_orgs
      $(org).children(".remove").click()
    scope.youxindata.organization_ids = []
]

@thirdstepCtrl = ["$scope",($scope)->
  $scope.icon_map1 =
    true: ""
    false: "-alt"

  $scope.msg_push = 
    active: true
    date: '5'
    full_msg: false    
  
  $scope.collectData = ()->
    this.msg_push.date = this.msg_push.date.replace(///\s///,"")
    if this.msg_push.active
      $scope.youxindata.delayed_sms_at = new Date().getTime()/1000 + parseFloat(this.msg_push.date) * 60 * 60    
    $scope.submit()
    self = $("#send-msg").find(".third-step")
    if (self.find(".nextStep").attr("disabled") is undefined)
      targetele = self.closest(".write-steps").find(".first-step")
      self.closest(".js-steps").hide()
      targetele.fadeIn(200)      
  
  $scope.$on "clearData",()->
    $scope.msg_push = 
      active: true
      date: '5'
      full_msg: false    
]