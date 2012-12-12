#= require_self
#= require teabag/base/runner
#= require teabag/base/reporters

class @Teabag
  @defer       : false
  @slow        : 75
  @fixturePath : null
  @finished    : false
  @Reporters   : {}
  @Date        : Date
  @location    : window.location

  @execute: ->
    if @defer
      @defer = false
      return
    new Teabag.Runner()
