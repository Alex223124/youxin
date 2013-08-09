# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require angularjs
#= require popuper
#= require notifications
#= require tool
#= require bootstrap-wysihtml5
#= require bootstrap-wysihtml5/locales/zh-CN
#= require bootstrap-notify
#= require jquery.form
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
        "<a class='dropdown-toggle' data-toggle='dropdown' href='#'>" +              
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
      
      "link" : (locale,options)->
        return "<li>" +
              "<div class='bootstrap-wysihtml5-insert-link-modal modal hidden fade'>" +
                "<div class='modal-header'>" +
                  "<a class='close' data-dismiss='modal'>&times;</a>" +
                  "<h3>" + locale.link.insert + "</h3>" +
                "</div>" +
                "<div class='modal-body'>" +
                  "<input value='http://' class='bootstrap-wysihtml5-insert-link-url input-xlarge'>" +
                  "<label class='checkbox'> <input type='checkbox' class='bootstrap-wysihtml5-insert-link-target' checked>" + locale.link.target + "</label>" +
                "</div>" +
                "<div class='modal-footer'>" +
                  "<a href='#' data-dismiss='modal'>" + locale.link.cancel + "</a>" +
                  "<a href='#' data-dismiss='modal'>" + locale.link.insert + "</a>" +
                "</div>" +
              "</div>" +
              "<a data-wysihtml5-command='createLink' title='" + locale.link.insert + "' tabindex='-1'><i class='icon-share'></i></a>" +
            "</li>"
    defaultOptions = 
      "font-styles": true
      "color": false
      "emphasis": true
      "lists": true
      "html": false
      "link": true
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

$(document).ready ->
  App.enableReplyBox()
  Youxin.initNotificationSubscribe()
  App.open()
  App.close()
  App.selectComponent()
