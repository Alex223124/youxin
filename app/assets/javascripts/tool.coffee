#= require fixed_alert

Array.prototype.objOfProperty = (_property,_value,_hasChildren)->
  _result = undefined
  for _item in this
    if _item[_property] is _value
      _result = _item
      break
    if _hasChildren isnt undefined and _hasChildren isnt null
      _children = _item[_hasChildren]
      if _children isnt undefined and _children isnt null
        _result = arguments.callee.call(_children,_property,_value,_hasChildren)
  _result

Array.prototype.indexOfProperty = (_property,_value)->
  _result = -1
  for _item,_i in this
    if _item[_property] is _value
      _result = _i
      break
  _result

Array.prototype.isInArrayOfProperty = (_property,_value)->
  _result = false
  for _item,_i in this
    if _item[_property] is _value
      _result = true
      break
  _result

Array.prototype.hasTwoInArrayOfProperty = (_property,_value)->
  _result = false
  _count = 0
  for _item,_i in this
    if _item[_property] is _value
      _count += 1
    if _count is 2
      _result = true
      break
  _result

Array.prototype.getIndex = (data)->
  for i,_index in this
    if i is data
      return _index
  return -1

Array.prototype.remove = (data)->
  if data instanceof Array
    for _i in data
      this.remove(_i)
  else
    for i, index in this
      if data is i
        this.splice(index, 1)
        return true
  false

Array.prototype.first = () ->
  @[0]

Array.prototype.last = () ->
  @[@.length - 1]

class Organization
  @all: []

  constructor: (attrs) ->
    for attr of attrs
      @[attr] = attrs[attr]
    @isLeafNode = true
    @expandFlag = false
    @selectFlag = false
    #@display = false

    @children ||= []

    @setParent()
    @setChildren()
    @setLevel()

    @constructor.all.push @

  setLevel : () ->
    if @parent
      @level = @parent.level + 1
    else
      @level = 0
    if @children.length > 0
      for organization in @children
        organization.setLevel()

  setParent : () ->
    for organization in @constructor.all
      if organization.id is @parent_id
        @parent = organization
        organization.children.push @
        organization.isLeafNode = false

  setChildren : () ->
    for organization in @constructor.all
      if organization.parent_id is @id
        @children.push organization
        organization.parent = @
        @isLeafNode = false

  @updateMembers : (organizations) ->
    for organization in organizations
      unless organization.isLeafNode
        @updateMembers(organization.children)
        organization.members_count = 0
        for child in organization.children
          organization.members_count += child.members_count

  @createAdditionalNodes : () ->
    for organization in @all
      unless organization.isLeafNode
        attrs = {}
        for attr of organization
          switch attr
            when 'id', 'avatar', 'members_count', 'name', 'parent_id'
              attrs[attr] = organization[attr]

        attrs.id = "parentNode-#{attrs.id}"
        attrs.parent_id = organization.id
        addtionalNode = new Organization(attrs)

        addtionalNode.id = organization.id
        organization.id = "parentNode-#{organization.id}"
        organization.name = "#{organization.name} 及以下组织"
    @updateMembers(@getAncestors())      

  @getAncestors : () ->
    ancestors = []
    for organization in @all
      ancestors.push organization unless organization.parent
    ancestors

  @setExpandFlag : (_value)->
    for organization in @all
      organization.expandFlag = _value

  @setIndex : (createAdditionalNodes) ->
    if createAdditionalNodes
      @createAdditionalNodes()
    self = @
    index = 0
    ((array)->
      for i in array
        ordered_organizations = self.all.splice(self.all.length - index)
        for organization, _index in self.all
          if organization.id is i.id
            self.all = self.all.concat self.all.splice(0, _index + 1)
            ordered_organizations.push self.all.pop()
            self.all = self.all.concat ordered_organizations
            break

        i.index = index
        index += 1
        if createAdditionalNodes
          arguments.callee(i.children.reverse())
        else
          arguments.callee(i.children)
    )(@getAncestors())

window.Organization = Organization
