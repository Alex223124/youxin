#= require jquery
#= require jquery_ujs
#= require bootstrap

window.Admin =
  enableTooltips : ()->
    options =
      placement: 'right'
    $('.admin-tooltip').tooltip(options)

$(document).ready ->
  Admin.enableTooltips()