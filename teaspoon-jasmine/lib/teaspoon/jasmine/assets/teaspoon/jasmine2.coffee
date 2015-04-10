#= require teaspoon/teaspoon
#= require_self
#= require_tree ./jasmine2

unless jasmineRequire?
  throw new Teaspoon.Error('Jasmine 2 not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')

@Teaspoon ?= {}
@Teaspoon.Jasmine2 ?= {}
@Teaspoon.Jasmine2.Reporters ?= {}
