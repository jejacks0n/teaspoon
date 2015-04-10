#= require teaspoon/reporters/html/progress_view

class Teaspoon.Reporters.HTML.RadialProgressView extends Teaspoon.Reporters.HTML.ProgressView

  @supported: !!document.createElement("canvas").getContext

  build: ->
    @el = @createEl("div", "teaspoon-indicator radial-progress")
    @el.innerHTML = """
      <canvas id="teaspoon-progress-canvas"></canvas>
      <em id="teaspoon-progress-percent">0%</em>
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
