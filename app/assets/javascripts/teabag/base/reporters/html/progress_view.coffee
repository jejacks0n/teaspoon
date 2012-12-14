class Teabag.Reporters.HTML.ProgressView extends Teabag.Reporters.BaseView

  @create: (displayProgress = true) ->
    return new Teabag.Reporters.HTML.ProgressView() unless displayProgress
    if Teabag.Reporters.HTML.RadialProgressView.supported
      new Teabag.Reporters.HTML.RadialProgressView()
    else
      Teabag.Reporters.HTML.SimpleProgressView()


  build: ->
    @el = @createEl("div", "teabag-indicator modeset-logo")


  update: ->
    # do nothing



class Teabag.Reporters.HTML.SimpleProgressView extends Teabag.Reporters.HTML.ProgressView

  build: ->
    @el = @createEl("div", "simple-progress")
    @el.innerHTML = """
      <em id="teabag-progress-percent">0%</em>
      <span id="teabag-progress-span" class="teabag-indicator"></span>
    """


  update: (total, run) ->
    percent = if total then Math.ceil((run * 100) / total) else 0
    @setHtml("progress-percent", "#{percent}%")



class Teabag.Reporters.HTML.RadialProgressView extends Teabag.Reporters.HTML.ProgressView

  @supported: !!document.createElement("canvas").getContext

  build: ->
    @el = @createEl("div", "teabag-indicator radial-progress")
    @el.innerHTML = """
      <canvas id="teabag-progress-canvas"></canvas>
      <em id="teabag-progress-percent">0%</em>
    """

  appendTo: ->
    super
    @size = 80
    try
      canvas = @findEl("progress-canvas")
      canvas.width = canvas.height = canvas.style.width = canvas.style.height = @size
      @ctx = canvas.getContext("2d")
      @ctx.strokeStyle = "#fff"
      @ctx.lineWidth = 1.5
    catch e # intentionally do nothing


  update: (total, run) ->
    percent = if total then Math.ceil((run * 100) / total) else 0
    @setHtml("progress-percent", "#{percent}%")
    return unless @ctx
    half = @size / 2
    @ctx.clearRect(0, 0, @size, @size)
    @ctx.beginPath()
    @ctx.arc(half, half, half - 1, 0, Math.PI * 2 * (percent / 100), false)
    @ctx.stroke()
