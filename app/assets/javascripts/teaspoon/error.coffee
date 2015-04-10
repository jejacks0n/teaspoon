class Teaspoon.Error extends Error

  constructor: (message) ->
    @name = "TeaspoonError"
    @message = (message || "")
