#= require support/json2

window.passing = true
window.failing = false

# create the log method on console in case it doesn't exist -- several tests rely on it being spied upon
window.console = {log: ->} unless window.console
