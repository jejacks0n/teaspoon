#= require teaspoon/teaspoon
#= require_self
#= require_tree ./qunit

unless QUnit?
  throw new Teaspoon.Error('QUnit not found -- use `suite.use_framework :qunit` and adjust or remove the `suite.javascripts` directive.')

@Teaspoon ?= {}
@Teaspoon.Qunit = {
  version: ->
    versions = @rawVersion().split('.')
    {major: versions[0], minor: versions[1], patch: versions[2]}


  rawVersion: ->
    QUnit.version || _qunit_version
}
@Teaspoon.Qunit.Reporters ?= {}
@Teaspoon.Qunit.Reporters.HTML ?= {}
