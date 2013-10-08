class Overlay
  constructor: (element, options) ->
    @element = $(element)
    @options = options
    @createDomTemplate()
    @pitchElement = @element.find(".pitch")
    @init()

  init: ()->
    @setPosition()
    @bindEvent()
    @

  createDomTemplate: ()->
    tpl = """
      <div class="pa container pitch">
        <div class="pr">
          <div class="logo"><img src="#{@options.img}" alt="picture"></div>
          <div class="content pa #{@options.dir} dib tal">
            <div class="pr">
              <i class="caret"></i>
              <div class="content-container">
                <div class="title">#{@options.title}</div>
                <span>#{@options.content}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
    @element.append tpl

  setPosition: ()->
    @pitchElement.css
      left: "-110%"
      top: "-120%"

  bindEvent: ()->
    showPitch = ()->
      $(@).find(".pitch").addClass "container-hover"
      mask = $(@).closest(".app-features").prev("div")
      mask.addClass("mask-show").removeClass("mask-hide")

    hidePitch = ()->
      $(@).find(".pitch").removeClass "container-hover"
      mask = $(@).closest(".app-features").prev("div")
      mask.addClass("mask-hide").removeClass("mask-show")

    @element.bind "mouseover", showPitch

    @element.bind "mouseout", hidePitch


$.fn.overlay = () ->
  @each ->
    $this = $(this)
    data = $this.data()
    new Overlay(this, data)
    # if (!data)
    #   $this.data("overlay", new Overlay(this, data))
    # if (typeof options is 'string')
    #   data[options]()

# $.fn.overlay = () ->
#   @each ->
#     $this = $(this)

$.fn.overlay.Constructor = Overlay

$ ()->
  $(".feature").overlay()