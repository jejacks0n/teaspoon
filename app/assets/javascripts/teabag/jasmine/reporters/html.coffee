class Teabag.Reporters.HTML extends Teabag.Reporters.HTML

  readConfig: ->
    super
    env.catchExceptions(@config["use-catch"]) if env.catchExceptions
    jasmine.CATCH_EXCEPTIONS = @config["use-catch"]


  envInfo: ->
    if ver = jasmine.version
      "jasmine #{ver}"
    else
      ver = jasmine.getEnv().version()
      verString = [ver.major, ver.minor, ver.build].join(".")
      "jasmine #{verString} revision #{ver.revision}"


# set the environment
env = jasmine.getEnv()
