window.fixed_alert = (msg)->
  msg = msg.toString()
  container = $(document.body).children('.alert-container')
  if container.length is 0
    container = $("<span class='alert-container'>")
    $(document.body).append(container)
  container.html(msg)
  container.css
    position: "fixed"
    top: "40px"
    padding: "5px 10px"
    display: "none"
    MsBorderRadius: "4px 4px 4px 4px"
    OBorderRadius: "4px 4px 4px 4px"
    MozBorderRadius: "4px 4px 4px 4px"
    borderRadius: "4px 4px 4px 4px"
    left: $(document.body).width() / 2 - container.width() / 2
    backgroundColor: "rgb(0,0,0)"
    color: "white"
    zIndex: 100000
  container.fadeTo(400,0.7).delay(4000).fadeOut(1000)