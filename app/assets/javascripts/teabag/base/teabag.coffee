#= require_self
#= require teabag/base/runner
#= require teabag/base/reporters

class @Teabag
  @defer: false
  @finished: false
  @slow: 75
  @fixturePath = null
  @Reporters = {}

  @execute: ->
    if @defer
      @defer = false
      return
    new Teabag.Runner()
