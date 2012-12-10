#= require_self
#= require_tree ./reporters

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


class Teabag.Runner

  constructor: ->
    return if @run
    @run = true
    @fixturePath = Teabag.fixturePath
    @setup()


  setup: ->
