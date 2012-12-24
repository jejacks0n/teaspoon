#= require_self
#= require teabag/base/models
#= require teabag/base/runner
#= require teabag/base/reporters/html
#= require teabag/base/reporters/console

class @Teabag
  @defer       : false
  @slow        : 75
  @fixturePath : null
  @finished    : false
  @Reporters   : {}
  @Date        : Date
  @location    : window.location
  @console     : window.console
  @messages    : []

  @execute: ->
    if @defer
      @defer = false
      return
    new Teabag.Runner()


  # logging methods -- used by selenium / phantomJS to get information back to ruby
  @log: ->
    @messages.push(arguments[0])
    @console.log(arguments...)


  @getMessages: ->
    messages = @messages
    @messages = []
    messages
