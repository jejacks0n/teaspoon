#= require teaspoon/reporters/html

class Teaspoon.Jasmine2.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  envInfo: ->
    "jasmine #{jasmine.version}"
