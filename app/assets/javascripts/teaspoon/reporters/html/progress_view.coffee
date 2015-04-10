#= require teaspoon/reporters/html/base_view

class Teaspoon.Reporters.HTML.ProgressView extends Teaspoon.Reporters.BaseView

  @create: (displayProgress = true) ->
    return new Teaspoon.Reporters.HTML.ProgressView() unless displayProgress
    if Teaspoon.Reporters.HTML.RadialProgressView.supported
      new Teaspoon.Reporters.HTML.RadialProgressView()
    else
      new Teaspoon.Reporters.HTML.SimpleProgressView()


  build: ->
    @el = @createEl("div", "teaspoon-indicator teaspoon-logo")


  update: ->
    # do nothing
