class Popuper
  constructor: (element) ->
    @element = $(element)
    @padding = 80
    @init()

  init: () ->
    @getDetail()

  show: ->
    self = @
    @setStartState()
    @setEndState()
    @createContainer()
    @popuper_container.css(@start_state)
    @popuper_container.animate(@end_state, 300)
    @popuper_backdrop.fadeIn(300)
    $.ajax(self.origin_src).done( ->
      self.popuper_container.find('img').attr('src', self.origin_src)
    ).fail( ->
      alert('error')
    )


  hide: ->
    @setStartState()
    @popuper_container.find('img').css({'width': '100%', 'height': '100%'})
    @popuper_container.animate(@start_state, 300)
    @popuper_backdrop.fadeOut(300)
    self = @
    setTimeout ( ->
      self.popuper_wrap.remove()
    ), 300

  getDetail: ->
    @img = @element.find('img')
    @src = @img.attr('src')
    @origin_dimension = @element.attr('data-origin-dimension')
    @origin_src = @element.attr('data-origin-src')
    @origin_name = @element.attr('data-origin-name')

  createContainer: ->
    @getWindowDimension()
    @popuper_wrap = $("<div class='popuper-wrap'></div>")
    @popuper_backdrop = $("<div class='popuper-backdrop' style='cursor: pointer; display: none; position: fixed; top: 0; right: 0; bottom: 0; left: 0; z-index: 1040; background-color: #000; opacity: 0.7; filter: alpha(opacity=70);'></div>")
    @popuper_container = $("<div class='popuper-container' style='text-align: center; position: absolute; z-index: 1050;'></div>").css(@pre_state)
    @popuper_container.append($("<img src='#{@src}' style='cursor: pointer; max-width: 10000px; width: #{@origin_dimension.width}px; height: #{@origin_dimension.height}px;' />"))
    popuper_optain = $("<div class='optain' style='color: whitesmoke; position: absolute; left: 50%; width: #{@window_dimension.width - @padding}px; margin-left: -#{(@window_dimension.width - @padding)/2}px;'><span class='name'>#{@origin_name}</span> [<a href='#{@origin_src}' target='_blank'>查看原图</a>]</div>")
    @popuper_container.append(popuper_optain)
    self = @
    $('body').on 'click', '.popuper-backdrop, .popuper-container img', ->
      self.hide()
    @popuper_wrap.append(@popuper_backdrop).append(@popuper_container)
    $('body').append(@popuper_wrap)

  getOriginDimension: ->
    @getWindowDimension()
    dimension = @origin_dimension.split(',')
    @origin_dimension =
      width: parseInt(dimension[0]),
      height: parseInt(dimension[1])
    if @window_dimension.height - @origin_dimension.height < @padding
      adjust_height = @window_dimension.height - @padding
      percentage = adjust_height/@origin_dimension.height
      @origin_dimension =
        width: @origin_dimension.width * percentage,
        height: @origin_dimension.height * percentage
    if @window_dimension.width - @origin_dimension.width < @padding
      adjust_width = @window_dimension.width - @padding
      percentage = adjust_width/@origin_dimension.width
      @origin_dimension =
        width: @origin_dimension.width * percentage,
        height: @origin_dimension.height * percentage

  
  getWindowDimension: ->
    @window_dimension =
      width: $(window).width(),
      height: $(window).height()

  getPreState: ->
    offset = @img.offset()
    @pre_state = 
      top: offset.top,
      left: offset.left,
      width: @img.width(),
      height: @img.height()

  setStartState: ->
    @getPreState()
    @start_state = @pre_state

  setEndState: ->
    @getWindowDimension()
    @getOriginDimension()
    @end_state =
      top: "#{(@window_dimension.height - @origin_dimension.height)/2}px",
      left: "#{(@window_dimension.width - @origin_dimension.width)/2}px",
      width: "#{@origin_dimension.width}px",
      height: "#{@origin_dimension.height}px"


$.fn.popuper = () ->
  @each ->
    $this = $(this)

$.fn.popuper.Constructor = Popuper

$(document).on 'click', '.popuper', ->
      popuper = new Popuper($(this))
      popuper.show()
