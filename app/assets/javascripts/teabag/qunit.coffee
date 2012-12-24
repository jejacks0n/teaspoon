#= require qunit-1.10.0
#= require teabag/base/teabag

class Teabag.Runner extends Teabag.Runner

  env = QUnit
  env.config.autostart = false
  env.config.altertitle = false

  constructor: ->
    super
    env.start()


  setup: ->
    env.done -> Teabag.finished = true
