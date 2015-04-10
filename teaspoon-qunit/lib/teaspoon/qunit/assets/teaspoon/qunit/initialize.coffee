Teaspoon.setFramework(Teaspoon.Qunit)

# set the environment
QUnit.config.autostart = false
QUnit.config.altertitle = false
QUnit.config.filter = Teaspoon.Runner.prototype.getParams()["grep"]

originalReset = QUnit.reset
QUnit.reset = ->
  originalReset()
  Teaspoon.Fixture.cleanup()
