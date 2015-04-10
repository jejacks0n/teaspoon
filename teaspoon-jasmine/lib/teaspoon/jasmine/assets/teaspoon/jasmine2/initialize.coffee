Teaspoon.setFramework(Teaspoon.Jasmine2)

# Jasmine 2 runs the spec filter when the #it block are evaluated. This
# means we need to set the filter upon page load, instead of when the
# runner is initialized. Since Jasmine is loaded into the page first, then
# the tests, then Teaspoon is initialized, this is set up to run early in
# the boot process.
setupSpecFilter = (env) ->
  if grep = Teaspoon.Runner::getParams()["grep"]
    env.specFilter = (spec) ->
      spec.getFullName().indexOf(grep) == 0

extend = (destination, source) ->
  for property of source
    destination[property] = source[property]
  destination


# Set up Jasmine 2
window.jasmine = jasmineRequire.core(jasmineRequire)
env = window.jasmine.getEnv()
setupSpecFilter(env)
extend(window, jasmineRequire.interface(jasmine, env))
