#= require_self
#= require teaspoon/base/runner
#= require teaspoon/base/fixture
#= require teaspoon/base/hook
#= require teaspoon/base/reporters/html
#= require teaspoon/base/reporters/console

class @Teaspoon
  @defer:     false
  @slow:      75
  @root:      window.location.pathname.replace(/\/+(index\.html)?$/, "").replace(/\/[^\/]*$/, "")
  @started:   false
  @finished:  false
  @Reporters: {}
  @Date:      Date
  @location:  window.location
  @messages:  []
  @params:    do ->
    params = {}
    for param in window.location.search.substring(1).split("&")
      [name, value] = param.split("=")
      params[decodeURIComponent(name)] = decodeURIComponent(value)
    params

  @execute: ->
    if Teaspoon.defer
      Teaspoon.defer = false
      return
    Teaspoon.reload() if Teaspoon.started
    Teaspoon.started = true
    new Teaspoon.Runner()


  @reload: ->
    window.location.reload()


  @onWindowLoad: (method) ->
    originalOnload = window.onload
    window.onload = ->
      originalOnload() if originalOnload && originalOnload.call
      method()


  @log: ->
    Teaspoon.messages.push(arguments[0])
    try console.log(arguments...)
    catch e
      throw new Error("Unable to use console.log for logging")


  @getMessages: ->
    messages = Teaspoon.messages
    Teaspoon.messages = []
    messages



class Teaspoon.Error extends Error

  constructor: (message) ->
    @name = "TeaspoonError"
    @message = (message || "")
