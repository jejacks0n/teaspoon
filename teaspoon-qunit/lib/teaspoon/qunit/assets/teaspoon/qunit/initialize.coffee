# set the environment
QUnit.config.autostart = false
QUnit.config.altertitle = false
QUnit.config.filter = Teaspoon.Runner.prototype.getParams()["grep"]

window.fixture = Teaspoon.fixture
originalReset = QUnit.reset
QUnit.reset = ->
  originalReset()
  Teaspoon.fixture.cleanup()
