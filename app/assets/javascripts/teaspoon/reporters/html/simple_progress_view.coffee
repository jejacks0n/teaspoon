#= require teaspoon/reporters/html/progress_view

class Teaspoon.Reporters.HTML.SimpleProgressView extends Teaspoon.Reporters.HTML.ProgressView

  build: ->
    @el = @createEl("div", "simple-progress")
    @el.innerHTML = """
      <em id="teaspoon-progress-percent">0%</em>
      <span id="teaspoon-progress-span" class="teaspoon-indicator"></span>
    """


  update: (total, run) ->
    percent = if total then Math.ceil((run * 100) / total) else 0
    @setHtml("progress-percent", "#{percent}%")
