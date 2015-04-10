#= require teaspoon/teaspoon
#= require_self
#= require_tree ./mocha

unless mocha?
  throw new Teaspoon.Error('Mocha not found -- use `suite.use_framework :mocha` and adjust or remove the `suite.javascripts` directive.')

@Teaspoon ?= {}
@Teaspoon.Mocha ?= {}
@Teaspoon.Mocha.Reporters ?= {}
