class Teabag.Fixture

  constructor: (@url) ->
    @url = "#{Teabag.root}/fixtures/#{@url}"
    @xhr = @xhrRequest()
    @load()


  load: ->
    @xhr.onreadystatechange = @complete
    @xhr.open("GET", @url)
    @xhr.send()


  complete: =>
    return unless @xhr.readyState == 4
    throw("There was a problem with the request.") unless @xhr.status == 200
    @handleResponse()


  handleResponse: ->
    type = @xhr.getResponseHeader("content-type")
    if type.match(/application\/json/)
      @content = JSON.parse(@xhr.responseText)
    else
      @content = @xhr.responseText
      # remove element
      el = document.getElementById("teabag-fixtures")
      el?.parentNode.removeChild(el)
      # add element with contents
      el = document.createElement("div")
      el.id = "teabag-fixtures"
      el.innerHTML = @content
      document.body.appendChild(el)


  xhrRequest: ->
    if window.XMLHttpRequest # Mozilla, Safari, ...
      xhr = new XMLHttpRequest()
    else if window.ActiveXObject # IE
      try xhr = new ActiveXObject("Msxml2.XMLHTTP")
      catch e
        try xhr = new ActiveXObject("Microsoft.XMLHTTP")
        catch e

    return xhr if xhr
    throw("Unable to make Ajax Request")
    return false
