#= require teaspoon/reporters/html

class Teaspoon.Jasmine2.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.getEnv().catchExceptions(@config["use-catch"])


  envInfo: ->
    "jasmine #{jasmine.version}"
