class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  envInfo: ->
    "jasmine #{jasmine.version}"
