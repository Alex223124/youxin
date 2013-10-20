Array.prototype.objOfProperty = (_property,_value,_hasChildren)->
  _result = undefined
  if @
    for _item in @
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
  for _item,_i in @
    if _item[_property] is _value
      _result = _i
      break
  _result

Array.prototype.isInArrayOfProperty = (_property,_value)->
  _result = false
  for _item,_i in @
    if _item[_property] is _value
      _result = true
      break
  _result

Array.prototype.hasTwoInArrayOfProperty = (_property,_value)->
  _result = false
  _count = 0
  for _item,_i in @
    if _item[_property] is _value
      _count += 1
    if _count is 2
      _result = true
      break
  _result

Array.prototype.getIndex = (data)->
  for i,_index in @
    if i is data
      return _index
  return -1

Array.prototype.remove = (data)->
  if data instanceof Array
    for _i in data
      @.remove(_i)
  else
    for i, index in @
      if data is i
        @.splice(index, 1)
        return true
  false

Array.prototype.first = () ->
  @[0]

if !Array.prototype.forEach
  Array.prototype.forEach = (fn, scope)->
    for _item,_i in @
      fn.call scope, _item, _i, @
      
Array.prototype.last = () ->
  @[@.length - 1]

Date.prototype.beginning_of_week = () ->
  day = @getDay()
  day = if day == 0 then 7 else day
  current_day = @getDate() - day + 1
  @setDate(current_day)
  @

pad = (str, length) ->
  str = str.toString()
  if str.length < length
    pad("0#{str}", length)
  else
    str

# class Organization
#   @all: []
#   @roots: []

#   constructor: (attrs) ->
#     for attr of attrs
#       @[attr] = attrs[attr]
#     @isLeafNode = true
#     @expandFlag = false
#     @selectFlag = false
#     #@display = false

#     @children ||= []

#     @setParent()
#     @setChildren()
#     @setLevel()

#     @constructor.all.push @

#   setLevel : () ->
#     if @parent
#       @level = @parent.level + 1
#     else
#       @level = 0
#     if @children.length > 0
#       for organization in @children
#         organization.setLevel()

#   setParent : () ->
#     if @.parent_id is null
#       @.constructor.roots.push @
#     for organization in @constructor.all
#       if organization.id is @parent_id
#         @parent = organization
#         organization.children.push @
#         organization.isLeafNode = false
#         break

#   setChildren : () ->
#     for organization in @constructor.all
#       if organization.parent_id is @id
#         @children.push organization
#         organization.parent = @
#         @isLeafNode = false

#   @updateMembers : (organizations) ->
#     for organization in organizations
#       unless organization.isLeafNode
#         @updateMembers(organization.children)
#         organization.members_count = 0
#         for child in organization.children
#           organization.members_count += child.members_count

#   @createAdditionalNodes : () ->
#     for organization in @all
#       unless organization.isLeafNode
#         attrs = {}
#         for attr of organization
#           switch attr
#             when 'id', 'avatar', 'members_count', 'name', 'parent_id'
#               attrs[attr] = organization[attr]

#         attrs.id = "parentNode-#{attrs.id}"
#         attrs.parent_id = organization.id
#         addtionalNode = new Organization(attrs)

#         addtionalNode.id = organization.id
#         organization.id = "parentNode-#{organization.id}"
#         organization.name = "#{organization.name} 及以下组织"
#     @updateMembers(@getAncestors())      

#   @getAncestors : () ->
#     ancestors = []
#     for organization in @all
#       ancestors.push organization unless organization.parent
#     ancestors

#   @setExpandFlag : (_value)->
#     for organization in @all
#       if organization.level < 1
#         organization.expandFlag = _value
#       else
#         organization.expandFlag = false

#   @setIndex : (createAdditionalNodes) ->
#     if createAdditionalNodes
#       @createAdditionalNodes()
#     self = @
#     index = 0
#     ((array)->
#       for i in array
#         ordered_organizations = self.all.splice(self.all.length - index)
#         for organization, _index in self.all
#           if organization.id is i.id
#             self.all = self.all.concat self.all.splice(0, _index + 1)
#             ordered_organizations.push self.all.pop()
#             self.all = self.all.concat ordered_organizations
#             break

#         i.index = index
#         index += 1
#         if createAdditionalNodes
#           arguments.callee(i.children.reverse())
#         else
#           arguments.callee(i.children)
#     )(@getAncestors())

#   @remove : (id) ->
#     for organization, index in @all
#       if organization.id is id
#         children = organization.children
#         @remove(children.first().id) while children.length

#         parent = organization.parent
#         for child, _index in parent.children
#           if child.id is id
#             parent.children.splice(_index, 1)
#             break

#         parent.isLeafNode = true unless parent.children.length

#         @all.splice(index, 1)
#         break

#     @setIndex()


class Organization
  @all: []
  constructor: (array)->
    for attr of array
      @[attr] = array[attr]
    @isLeafNode = true
    @expandFlag = false
    @selectFlag = false
    @children = []
    @setParent()
    @setChildren()
    @setLevel()
    @constructor.all.push @

  setLevel : () ->
    if @parent
      @level = @parent.level + 1
    else
      @level = 0
    if @children.length and @children.length > 0
      for organization in @children
        organization.setLevel()

  setParent : () ->
    for organization in @constructor.all
      if organization.id is @parent_id
        @parent = organization
        organization.children.push @
        organization.isLeafNode = false
        break

  setChildren : () ->
    for organization in @constructor.all
      if organization.parent_id is @id
        @children.push organization
        organization.parent = @
        @isLeafNode = false

  @getRoots: ()->
    _result = []
    for _item in @all
      if _item.parent_id is null
        _result.push _item
    _result
    

  @rootFirstOrder: ()->
    _cache = []
    _count = 0
    _order_main = (roots)->
      for organization in roots
        organization.index = _count
        _count += 1
        _cache.push(organization)
        if organization.children
          arguments.callee(organization.children)
      true
    _order_main(Organization.getAncestors())
    _cache

 
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
      if organization.level < 1
        organization.expandFlag = _value
      else
        organization.expandFlag = false

  @setIndex: (createAdditionalNodes)->
    if createAdditionalNodes
      @createAdditionalNodes()
    @all = @rootFirstOrder()

  @remove: (id)->
    for organization, index in @all
      if organization.id is id
        children = organization.children
        @remove(children.first().id) while children.length

        parent = organization.parent
        for child, _index in parent.children
          if child.id is id
            parent.children.splice(_index, 1)
            break

        parent.isLeafNode = true unless parent.children.length

        @all.splice(index, 1)
        break

    @setIndex()


window.Organization = Organization
window.pad = pad
