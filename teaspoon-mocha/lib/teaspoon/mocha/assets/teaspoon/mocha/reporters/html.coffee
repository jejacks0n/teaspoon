#= require teaspoon/reporters/html

class Teaspoon.Mocha.Reporters.HTML extends Teaspoon.Reporters.HTML

  reportSpecResults: (spec) ->
    # Mocha does not report pending specs as starting, only as completed with a
    # pending state. So, we need to instantiate the view for the pending spec.
    if spec.pending
      @reportView = new Teaspoon.Mocha.Reporters.HTML.SpecView(spec, @) if @config["build-full-report"]
    super(spec)


  envInfo: ->
    "mocha #{_mocha_version || "[unknown version]"}"
