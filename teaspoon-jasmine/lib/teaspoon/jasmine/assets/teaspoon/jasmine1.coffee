#= require teaspoon/teaspoon
#= require_self
#= require_tree ./jasmine1

unless jasmine?
  throw new Teaspoon.Error('Jasmine 1 not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')

@Teaspoon ?= {}
@Teaspoon.Jasmine1 ?= {}
@Teaspoon.Jasmine1.Reporters ?= {}
