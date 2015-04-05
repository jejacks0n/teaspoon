class Teaspoon.Reporters.HTML extends Teaspoon.Reporters.HTML

  readConfig: ->
    super
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  envInfo: ->
    ver = jasmine.getEnv().version()
    verString = [ver.major, ver.minor, ver.build].join(".")
    "jasmine #{verString} revision #{ver.revision}"
