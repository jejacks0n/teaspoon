class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  envInfo: ->
    "mocha #{_mocha_version || "[unknown version]"}"


class Teaspoon.Reporters.HTML.SpecView extends Teaspoon.Reporters.HTML.SpecView

  updateState: (state) ->
    super(state, @spec.spec.duration)
