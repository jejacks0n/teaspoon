#= require teaspoon/base/teaspoon
#= require teaspoon/jasmine2/_namespace
#= require teaspoon/jasmine2/spec
#= require teaspoon/jasmine2/suite
#= require teaspoon/jasmine2/runner
#= require teaspoon/jasmine2/fixture
#= require teaspoon/jasmine2/responder
#= require teaspoon/jasmine2/reporters/console
#= require teaspoon/jasmine2/reporters/html

unless jasmineRequire?
  throw new Teaspoon.Error('Jasmine 2 not found -- use `suite.use_framework :jasmine` and adjust or remove the `suite.javascripts` directive.')


Teaspoon.Jasmine2.Runner.setup()
