#= require teaspoon/reporters/html/spec_view

class Teaspoon.Mocha.Reporters.HTML.SpecView extends Teaspoon.Reporters.HTML.SpecView

  updateState: (state) ->
    super(state, @spec.spec.duration)
