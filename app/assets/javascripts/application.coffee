#= require jquery
#= require jquery_ujs
#= require bootstrap-transition
#= require bootstrap-alert
#= require bootstrap-dropdown
#= require bootstrap-collapse
#= require bootstrap-tab
#= require bootstrap-tooltip
#= require tool
#= require angularjs
#= require popuper
#= require notifications
#= require bootstrap-wysihtml5
#= require bootstrap-wysihtml5/locales/zh-CN
#= require bootstrap-notify
#= require bootstrap-datepicker/core
#= require bootstrap-datepicker/locales/bootstrap-datepicker.zh-CN

#= require jquery.form
#= require unread_bubble
#= require_self

window.App =
  selectComponent : ()->
    _body = $("body")
    _body.on "click",".radio-select",(ev)->
      _self = $(this)
      _list = _self.children("ul")
      _showing = _list.css("display")
      if _showing is "block"
        _list.animate({marginTop: "-10px",opacity:"hide"},300)
        _body.removeData("radio-select")
      else
        _list.animate({marginTop: "5px",opacity: "show"},300)
        if _body.data("radio-select") isnt undefined
          _body.data("radio-select").animate({marginTop: "-10px",opacity:"hide"},300)
        _body.data("radio-select",_list)
      ev.stopPropagation()

    _body.on "click",".radio-select ul>li",()->
      _self = $(this)
      _val = _self.text()
      _self.closest("ul").find(".selected").removeClass("selected")
      thisId = _self.attr("option-id")
      _button = _self.closest("ul").prev().find("[option-id]")
      _button.attr("option-id",thisId).text(_val)
      _self.addClass("selected")

    _body.click ()->
      _select_ele = $(this).data("radio-select")
      if _select_ele isnt undefined
        _select_ele.animate({marginTop: "-10px",opacity:"hide"},300)
        _body.removeData("radio-select")

  enableReplyBox : () ->
    $('.main-content').on 'focus', '.reply-box textarea', ->
      $(this).css('height', '60px')
      $(this).closest('.reply-box').find('.tools').show()
    $('.main-content').on 'click', '.reply-box a.btn-cancel', ->
      $(this).closest('.reply-box').find('textarea').css('height', '20px').val('')
      $(this).closest('.tools').hide()
  open : ()->
    $(document).on "click",".open",()->
      self = $(this)
      showtarget = self.attr("data-open")
      targetEle = $(showtarget)
      targetEle.show(200)
  close : ()->
    $(document).on "click",".close",()->
      self = $(this)
      scope = self.attr("scope")
      targetEle = self.closest(scope)
      if self.hasClass("open")
        targetEle.hide()
      else
        targetEle.hide(200)
      false
  richText : ()->
    myCustomTemplates =
      "font-styles" : (locale,options)->
        return "<li class='dropdown'>" +
        "<a class='dropdown-toggle' data-toggle='dropdown' href='javascript:;'>" +
        "<i class='icon-font'></i>&nbsp;<span class='current-font'>" + locale.font_styles.normal + "</span>&nbsp;<i class='icon icon-caret-down'></i>" + "</a>" +
        "<ul class='dropdown-menu dropdown-left'>" +
            "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='div' tabindex='-1'>" + locale.font_styles.normal + "</a></li>" +
            "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h4'>" + locale.font_styles.h3 + "</a></li>" +
          "</ul>" +
        "</li>"

      "emphasis" : (locale,options)->
        return "<li>" +
                "<a data-wysihtml5-command='bold' title='CTRL+B' tabindex='-1'>" + locale.emphasis.bold + "</a>" +
                "<a data-wysihtml5-command='italic' title='CTRL+I' tabindex='-1'>" + locale.emphasis.italic + "</a>" +
                "<a data-wysihtml5-command='underline' title='CTRL+U' tabindex='-1'>" + locale.emphasis.underline + "</a>" +
            "</li>"

      "lists" : (locale,options)->
        return "<li>" +
                "<a data-wysihtml5-command='insertUnorderedList' title='" + locale.lists.unordered + "' tabindex='-1'><i class='icon-list'></i></a>" +
                "<a data-wysihtml5-command='insertOrderedList' title='" + locale.lists.ordered + "' tabindex='-1'><i class='icon-th-list'></i></a>" +
                "<a data-wysihtml5-command='Outdent' title='" + locale.lists.outdent + "' tabindex='-1'><i class='icon-indent-right'></i></a>" +
                "<a data-wysihtml5-command='Indent' title='" + locale.lists.indent + "' tabindex='-1'><i class='icon-indent-left'></i></a>" +
             "</li>"

    defaultOptions =
      "font-styles": true
      "color": false
      "emphasis": true
      "lists": true
      "html": false
      "link": false
      "image": false
      locale: "zh-CN"
      customTemplates: myCustomTemplates
    richedit = $("#wysihtml5-textarea")
    richedit.wysihtml5(defaultOptions)

  alert : (message, type = 'success') ->
    return false unless message
    $('.notifications.center').notify
      message: message
      type: type
    .show()

  closePostProfile: ()->
    element = angular.element(document.getElementById("single_receipt"))
    element.scope().ctrl.closeReceipt()

  enableTooltip: () ->
    $('.youxin-tooltip').tooltip()
$(document).ready ->
  App.enableReplyBox()
  Youxin.initNotificationSubscribe()
  App.open()
  App.close()
  App.selectComponent()
  App.enableTooltip()
