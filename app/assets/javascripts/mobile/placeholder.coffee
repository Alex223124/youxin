placeholders = $(".for-placeholder").find("input[placeholder]")

placeholders.each ()->
  self = $(this)
  placeholder_content = self.attr("placeholder")
  if not $(this).next("span.placeholder").length
    $(this).after("<span class='placeholder'>#{placeholder_content}</span>")  

placeholders.bind "keyup", ()->
  if not $(this).val() then $(this).next("span.placeholder").show() else $(this).next("span.placeholder").hide()