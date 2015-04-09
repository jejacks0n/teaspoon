#= require teaspoon/teaspoon
#= require_self
#= require_tree ./qunit

unless QUnit?
  throw new Teaspoon.Error('QUnit not found -- use `suite.use_framework :qunit` and adjust or remove the `suite.javascripts` directive.')

@Teaspoon ?= {}
@Teaspoon.Qunit ?= {}
