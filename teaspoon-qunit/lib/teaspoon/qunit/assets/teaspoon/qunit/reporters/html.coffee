#= require teaspoon/reporters/html

class Teaspoon.Qunit.Reporters.HTML extends Teaspoon.Reporters.HTML

  reportRunnerResults: (runner) ->
    version = Teaspoon.Qunit.version()
    if version.major = 1 && version.minor < 16
      # QUnit <= 1.15 doesn't provide the total until all tests are finished
      # The .begin hook is broken
      @total.exist = @total.run = runner.total
    super


  readConfig: ->
    super
    QUnit.config.notrycatch = @config["use-catch"]


  envInfo: ->
    "qunit #{Teaspoon.Qunit.rawVersion() || "[unknown version]"}"
